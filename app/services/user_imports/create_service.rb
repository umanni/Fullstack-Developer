require 'stringio'
require 'roo'

module UserImports
  class CreateService
    def initialize(user_import)
      @user_import = user_import
    end

    def call
      parse_spreadsheet
    rescue StandardError => e
      handle_error(e)
    end

    private

    attr_reader :user_import

    def parse_spreadsheet
      user_import.update(status: :processing)
      broadcast_status_update
      
      file = user_import.spreadsheet_file.download
      extension = file_extension
      
      Rails.logger.info("Processing file with extension: #{extension}, content_type: #{user_import.spreadsheet_file.blob.content_type}")
      
      spreadsheet = Roo::Spreadsheet.open(StringIO.new(file), extension: extension)

      header_row = spreadsheet.row(1)
      Rails.logger.info("Header row: #{header_row.inspect}")
      
      validate_header(header_row)

      last_row = spreadsheet.last_row
      Rails.logger.info("Last row number: #{last_row}")
      
      data_rows_count = 0
      (2..last_row).each do |row_num|
        row = spreadsheet.row(row_num)
        data_rows_count += 1 unless row.all?(&:blank?)
      end
      
      total_rows = data_rows_count
      Rails.logger.info("Total data rows found: #{total_rows} (last_row: #{last_row})")

      user_import.update(total_rows: total_rows)

      if total_rows > 0
        process_rows(spreadsheet, header_row, total_rows)
      else
        current_errors = Array(user_import.error_messages || [])
        user_import.update(
          status: :failed,
          error_messages: current_errors + ["No data rows found in spreadsheet. Last row: #{last_row}"]
        )
      end
    end

    def file_extension
      return :xlsx unless user_import.spreadsheet_file.attached?
      
      blob = user_import.spreadsheet_file.blob
      return :xlsx unless blob
      
      content_type = blob.content_type
      filename = blob.filename.to_s
      
      case content_type
      when 'text/csv', 'application/csv'
        :csv
      when 'application/vnd.ms-excel', 'application/excel'
        :xls
      when 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        :xlsx
      else
        if filename.downcase.end_with?('.csv')
          :csv
        elsif filename.downcase.end_with?('.xls')
          :xls
        elsif filename.downcase.end_with?('.xlsx')
          :xlsx
        else
          :xlsx # default
        end
      end
    end

    def validate_header(header_row)
      return if header_row.nil? || header_row.empty?
      
      accepted_full_name_variations = ['full_name', 'full name', 'name']
      accepted_email_variations = ['email', 'e-mail']
      
      header_lowercase = header_row.map(&:to_s).map(&:downcase).map(&:strip)
      
      has_full_name = header_lowercase.any? { |h| accepted_full_name_variations.include?(h) }
      has_email = header_lowercase.any? { |h| accepted_email_variations.include?(h) }

      missing_columns = []
      missing_columns << 'full_name' unless has_full_name
      missing_columns << 'email' unless has_email

      return if missing_columns.empty?

      raise ArgumentError, "Missing required columns: #{missing_columns.join(', ')}. Found: #{header_lowercase.join(', ')}"
    end

    def process_rows(spreadsheet, header_row, total_rows)
      success_count = 0
      error_count = 0
      error_messages = []
      processed_count = 0

      Rails.logger.info("Processing rows from 2 to #{spreadsheet.last_row}")
      
      (2..spreadsheet.last_row).each do |row_num|
        row = spreadsheet.row(row_num)
        Rails.logger.info("Row #{row_num}: #{row.inspect}")
        
        next if row.all?(&:blank?)

        processed_count += 1
        user_data = build_user_data(row, header_row)
        Rails.logger.info("User data for row #{row_num}: #{user_data.inspect}")
        
        create_user(user_data, row_num, error_messages) ? success_count += 1 : error_count += 1

        user_import.update(
          processed_rows: processed_count,
          success_count: success_count,
          error_count: error_count,
          error_messages: error_messages
        )

        broadcast_progress(processed_count, total_rows)
      end

      Rails.logger.info("Processing completed: #{success_count} success, #{error_count} errors")
      user_import.update(status: :completed)
      broadcast_completion
    rescue StandardError => e
      Rails.logger.error("Error in process_rows: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      user_import.update(status: :failed)
      raise e
    end

    def build_user_data(row, header_row)
      data = {}
      header_row.each_with_index do |header, index|
        key = header.to_s.downcase.strip
        value = row[index]&.to_s&.strip

        case key
        when 'full_name', 'full name', 'name'
          data[:full_name] = value
        when 'email', 'e-mail'
          data[:email] = value
        when 'role', 'user_role'
          data[:role] = value&.downcase == 'admin' ? :admin : :user
        when 'avatar_url', 'avatar', 'avatar url'
          data[:avatar_url] = value
        end
      end

      data[:role] ||= :user
      data
    end

    def create_user(user_data, row_num, error_messages)
      user = User.new(user_data)
      user.password = Devise.friendly_token[0, 20] if user.password.blank?

      if user.save
        true
      else
        error_messages << "Row #{row_num}: #{user.errors.full_messages.join(', ')}"
        false
      end
    rescue StandardError => e
      error_messages << "Row #{row_num}: #{e.message}"
      false
    end

    def broadcast_status_update
      user_import.reload
      ActionCable.server.broadcast(
        "import_progress_#{user_import.id}",
        {
          type: 'progress',
          processed_rows: user_import.processed_rows || 0,
          total_rows: user_import.total_rows || 0,
          success_count: user_import.success_count || 0,
          error_count: user_import.error_count || 0,
          status: user_import.status,
          progress: 0
        }
      )
    end

    def broadcast_progress(processed, total)
      user_import.reload
      ActionCable.server.broadcast(
        "import_progress_#{user_import.id}",
        {
          type: 'progress',
          processed_rows: processed,
          total_rows: total,
          success_count: user_import.success_count,
          error_count: user_import.error_count,
          status: user_import.status,
          progress: total > 0 ? ((processed.to_f / total) * 100).round(2) : 0
        }
      )
    end

    def broadcast_completion
      user_import.reload
      ActionCable.server.broadcast(
        "import_progress_#{user_import.id}",
        {
          type: 'completed',
          status: user_import.status,
          processed_rows: user_import.processed_rows,
          total_rows: user_import.total_rows,
          success_count: user_import.success_count,
          error_count: user_import.error_count,
          progress: 100
        }
      )
    end

    def handle_error(error)
      current_errors = Array(user_import.error_messages || [])
      user_import.update(
        status: :failed,
        error_messages: current_errors + [error.message]
      )
      broadcast_error(error)
      Rails.logger.error("UserImport #{user_import.id} failed: #{error.message}")
      Rails.logger.error(error.backtrace.join("\n")) if error.backtrace
    end

    def broadcast_error(error)
      ActionCable.server.broadcast(
        "import_progress_#{user_import.id}",
        {
          type: 'error',
          message: error.message
        }
      )
    end
  end
end

