class UserImportJob < ApplicationJob
  queue_as :default

  MAX_ROWS = 10_000
  MAX_ROW_ERRORS = 100
  ROW_LIMIT_ERROR = "File exceeds the 10,000 row limit"

  def perform(user_import)
    Rails.logger.info("[UserImportJob] started import_id=#{user_import.id}")
    user_import.update!(status: :processing, row_errors: [], processed_rows: 0, failed_rows: 0)
    @errors_truncated = false

    begin
      rows = read_rows(user_import)
      user_import.update!(total_rows: rows.size)

      if rows.size > MAX_ROWS
        Rails.logger.warn("[UserImportJob] rejected import_id=#{user_import.id} rows=#{rows.size} exceeds limit")
        user_import.update!(status: :failed, row_errors: [ { row: nil, email: nil, error: ROW_LIMIT_ERROR } ])
        broadcast(user_import, include_errors: true)
        return
      end

      rows.each_with_index do |row, index|
        email = row["email"].to_s.strip.downcase
        if email.blank? || email == "email"
          user_import.increment!(:failed_rows)
          append_error(user_import, index + 2, email, "Email is blank")
          next
        end

        begin
          User.create!(
            full_name: row["full_name"].to_s,
            email: email,
            password: row["password"].to_s,
            password_confirmation: row["password"].to_s
          )
          user_import.increment!(:processed_rows)
        rescue ActiveRecord::RecordInvalid => e
          user_import.increment!(:failed_rows)
          append_error(user_import, index + 2, email, e.record.errors.full_messages.join(", "))
        end
        user_import.reload
        broadcast(user_import)
      end

      user_import.update!(status: user_import.failed_rows.positive? && user_import.processed_rows.zero? ? :failed : :completed)
      Rails.logger.info("[UserImportJob] completed import_id=#{user_import.id} processed=#{user_import.processed_rows} failed=#{user_import.failed_rows}")
      broadcast(user_import, include_errors: true)
    rescue StandardError => e
      Rails.logger.error("[UserImportJob] failed import_id=#{user_import.id} error=#{e.class}: #{e.message}")
      user_import.update!(status: :failed)
      broadcast(user_import, include_errors: true)
      raise
    end
  end

  private
    def append_error(user_import, row_number, email, message)
      if user_import.row_errors.size < MAX_ROW_ERRORS
        user_import.update!(row_errors: user_import.row_errors + [ { row: row_number, email: email, error: message } ])
      else
        @errors_truncated = true
      end
    end

    def broadcast(user_import, include_errors: false)
      payload = {
        status: user_import.status, total_rows: user_import.total_rows,
        processed_rows: user_import.processed_rows, failed_rows: user_import.failed_rows,
        progress_percent: user_import.progress_percent
      }
      if include_errors
        payload[:row_errors] = user_import.row_errors
        payload[:errors_truncated] = true if @errors_truncated
      end
      UserImportChannel.broadcast_to(user_import, payload)
    end

    def read_rows(user_import)
      file = user_import.file
      ext = File.extname(file.filename.to_s).downcase
      path = ActiveStorage::Blob.service.path_for(file.key)
      if ext == ".csv"
        CSV.read(path, headers: true).map(&:to_h)
      else
        workbook = RubyXL::Parser.parse(path)
        sheet = workbook[0]
        headers = sheet[0].cells.map { |c| c&.value.to_s }
        sheet.drop(1).filter_map do |row|
          next if row.cells.all? { |c| c&.value.nil? }
          headers.zip(row.cells.map { |c| c&.value }).to_h
        end
      end
    end
end
