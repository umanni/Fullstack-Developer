module UserImports
  class SpreadsheetReader
    class Error < StandardError; end

    REQUIRED_HEADERS = %w[full_name email].freeze
    OPTIONAL_HEADERS = %w[role].freeze
    MAX_ROWS = 5_000

    def initialize(user_import)
      @user_import = user_import
    end

    def each_row
      return enum_for(__method__) unless block_given?

      user_import.spreadsheet.blob.open do |file|
        sheet = open_sheet(file.path)
        headers = normalized_headers(sheet.row(1))
        validate_headers!(headers)
        validate_size!(sheet)

        (2..sheet.last_row.to_i).each do |row_number|
          values = sheet.row(row_number)
          next if values.all?(&:blank?)

          yield row_number, build_payload(headers, values)
        end
      end
    rescue Roo::Error, CSV::MalformedCSVError, Zip::Error => error
      raise Error, "The spreadsheet could not be read: #{error.message}"
    end

    private
      attr_reader :user_import

      def open_sheet(path)
        extension = user_import.spreadsheet.filename.extension_without_delimiter.downcase
        Roo::Spreadsheet.open(path, extension: extension)
      end

      def normalized_headers(values)
        values.map { |value| value.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "_").delete_suffix("_") }
      end

      def validate_headers!(headers)
        missing = REQUIRED_HEADERS - headers
        return if missing.empty?

        raise Error, "Missing required columns: #{missing.join(', ')}"
      end

      def validate_size!(sheet)
        data_rows = [ sheet.last_row.to_i - 1, 0 ].max
        raise Error, "The spreadsheet cannot contain more than #{MAX_ROWS.to_fs(:delimited)} rows." if data_rows > MAX_ROWS
      end

      def build_payload(headers, values)
        row = headers.zip(values).to_h.slice(*(REQUIRED_HEADERS + OPTIONAL_HEADERS))

        {
          "full_name" => row.fetch("full_name", "").to_s.squish,
          "email" => row.fetch("email", "").to_s.strip.downcase,
          "role" => normalize_role(row["role"])
        }
      end

      def normalize_role(value)
        normalized = value.to_s.strip.downcase
        return "user" if normalized.blank? || normalized.in?(%w[user no-admin non-admin])

        normalized
      end
  end
end
