require "csv"
require "roo"

module Users
  # Parses a spreadsheet and creates member users asynchronously tracked by UserImport.
  class Importer
    Result = Data.define(:successful, :failed, :errors)

    HEADERS = {
      "full_name" => :full_name,
      "fullname" => :full_name,
      "name" => :full_name,
      "email" => :email_address,
      "email_address" => :email_address,
      "password" => :password,
      "avatar_url" => :avatar_url,
      "role" => :role
    }.freeze

    def initialize(user_import)
      @user_import = user_import
    end

    def self.call(user_import)
      new(user_import).call
    end

    def call
      rows = parse_rows
      @user_import.update!(status: :processing, total_rows: rows.size, processed_rows: 0, successful_rows: 0, failed_rows: 0)

      successful = 0
      failed = 0
      errors = []

      rows.each_with_index do |row, index|
        attrs = normalize_row(row)
        user = User.new(attrs.merge(role: attrs[:role].presence || "member"))
        user.password ||= SecureRandom.alphanumeric(16)

        if user.save
          successful += 1
        else
          failed += 1
          errors << "Row #{index + 2}: #{user.errors.full_messages.to_sentence}"
        end

        @user_import.update!(
          processed_rows: index + 1,
          successful_rows: successful,
          failed_rows: failed
        )
      end

      @user_import.update!(
        status: :completed,
        error_message: errors.first(20).join("\n").presence
      )

      Result.new(successful: successful, failed: failed, errors: errors)
    rescue StandardError => e
      @user_import.update!(status: :failed, error_message: e.message)
      raise
    end

    private

    def parse_rows
      @user_import.spreadsheet.open do |file|
        path = file.path
        filename = @user_import.spreadsheet.filename.to_s.downcase

        if filename.end_with?(".csv")
          parse_csv(path)
        else
          parse_xlsx(path)
        end
      end
    end

    def parse_csv(path)
      table = CSV.read(path, headers: true)
      table.map(&:to_h)
    end

    def parse_xlsx(path)
      spreadsheet = Roo::Spreadsheet.open(path)
      sheet = spreadsheet.sheet(0)
      headers = sheet.row(1).map { |h| h.to_s.strip.downcase }

      (2..sheet.last_row).map do |i|
        headers.zip(sheet.row(i)).to_h
      end
    end

    def normalize_row(row)
      mapped = {}
      row.each do |key, value|
        attribute = HEADERS[key.to_s.strip.downcase]
        next unless attribute

        mapped[attribute] = value.to_s.strip.presence
      end

      if mapped[:role].present?
        role = mapped[:role].to_s.downcase
        mapped[:role] = role.in?(%w[admin administrator]) ? "admin" : "member"
      end

      mapped
    end
  end
end
