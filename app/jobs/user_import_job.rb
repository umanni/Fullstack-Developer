class UserImportJob < ApplicationJob
  queue_as :default

  def perform(import)
    import.update!(status: "processing", processed_rows: 0, successful_rows: 0, failed_rows: 0)

    begin
      process_import(import)
      import.update!(status: "completed")
    rescue StandardError => e
      import.update!(status: "failed")
      import.add_error("Import failed: #{e.message}")
      raise e
    end
  end

  private

  def process_import(import)
    file_path = download_file(import)

    spreadsheet = open_spreadsheet(file_path, import.file_name)
    headers = spreadsheet.row(1)

    validate_headers(headers, import)

    total_rows = spreadsheet.last_row - 1
    import.update!(total_rows: total_rows)

    (2..spreadsheet.last_row).each_with_index do |row_num, index|
      row = spreadsheet.row(row_num)
      process_row(row, headers, import)

      if (index + 1) % 10 == 0 || (index + 1) == total_rows
        import.update_progress!
        broadcast_progress(import)
      end
    end

    File.delete(file_path) if File.exist?(file_path)
  end

  def download_file(import)
    temp_file = Tempfile.new([ import.file_name, File.extname(import.file_name) ])
    temp_file.binmode
    temp_file.write(import.file.download)
    temp_file.close
    temp_file.path
  end

  def open_spreadsheet(file_path, filename)
    case File.extname(filename).downcase
    when ".csv"
      Roo::CSV.new(file_path)
    when ".xls"
      Roo::Excel.new(file_path)
    when ".xlsx"
      Roo::Excelx.new(file_path)
    else
      raise "Unknown file type: #{filename}"
    end
  end

  def validate_headers(headers, import)
    required_headers = [ "full_name", "email" ]
    optional_headers = [ "role", "avatar_url" ]

    missing_headers = required_headers - headers.map(&:to_s).map(&:downcase)

    if missing_headers.any?
      raise "Missing required headers: #{missing_headers.join(', ')}"
    end
  end

  def process_row(row, headers, import)
    begin
      user_data = build_user_data(row, headers)

      user = User.find_by(email: user_data[:email])

      if user
        user.update!(user_data.except(:email))
        import.increment!(:successful_rows)
      else
        user = User.create!(user_data.merge(password: generate_password))
        import.increment!(:successful_rows)
      end

      import.increment!(:processed_rows)

    rescue StandardError => e
      import.increment!(:failed_rows)
      import.increment!(:processed_rows)
      import.add_error("Row #{import.processed_rows}: #{e.message}")
    end
  end

  def build_user_data(row, headers)
    data = {}

    headers.each_with_index do |header, index|
      value = row[index]
      next if value.blank?

      case header.to_s.downcase
      when "full_name"
        data[:full_name] = value.to_s.strip
      when "email"
        data[:email] = value.to_s.strip.downcase
      when "role"
        role = value.to_s.strip.downcase
        data[:role] = %w[admin user].include?(role) ? role : "user"
      when "avatar_url"
        data[:avatar_url] = value.to_s.strip if valid_url?(value.to_s.strip)
      end
    end

    data
  end

  def generate_password
    SecureRandom.alphanumeric(12)
  end

  def valid_url?(url)
    uri = URI.parse(url)
    %w[http https].include?(uri.scheme)
  rescue URI::InvalidURIError
    false
  end

  def broadcast_progress(import)
    ActionCable.server.broadcast(
      "import_#{import.id}",
      {
        type: "progress_update",
        import: {
          id: import.id,
          progress: import.progress,
          processed_rows: import.processed_rows,
          total_rows: import.total_rows,
          successful_rows: import.successful_rows,
          failed_rows: import.failed_rows,
          status: import.status
        }
      }
    )
  end
end
