require "csv"

module Imports
  class SpreadsheetParser
    class Error < StandardError; end

    REQUIRED_HEADERS = %w[full_name email avatar_image_url].freeze
    OPTIONAL_HEADERS = %w[role].freeze
    MAX_ROWS = 1_000
    MAX_XLSX_ENTRIES = 1_000
    MAX_XLSX_UNCOMPRESSED_SIZE = 25.megabytes
    Row = Data.define(:number, :attributes)

    def self.call(user_import)
      new(user_import).call
    end

    def initialize(user_import)
      @user_import = user_import
    end

    def call
      user_import.spreadsheet.blob.open do |file|
        extension = File.extname(user_import.spreadsheet.filename.to_s).downcase
        rows = extension == ".csv" ? csv_rows(file.path) : xlsx_rows(file.path)
        raise Error, "The spreadsheet must contain at least one data row." if rows.empty?
        raise Error, "The spreadsheet cannot contain more than #{MAX_ROWS} data rows." if rows.length > MAX_ROWS

        rows
      end
    rescue CSV::MalformedCSVError, Roo::Error, Zip::Error
      raise Error, "The spreadsheet could not be parsed. Verify the file format and try again."
    end

    private
      attr_reader :user_import

      def csv_rows(path)
        table = CSV.read(path, headers: true, encoding: "bom|utf-8")
        headers = normalized_headers(table.headers)
        validate_headers!(headers)

        table.each_with_index.filter_map do |row, index|
          attributes = row.to_h.transform_keys { |key| normalize_header(key) }
          build_row(index + 2, attributes) unless blank_row?(attributes)
        end
      end

      def xlsx_rows(path)
        validate_xlsx_archive!(path)
        sheet = Roo::Excelx.new(path).sheet(0)
        reject_oversized_sheet!(sheet)
        headers = normalized_headers(sheet.row(1))
        validate_headers!(headers)

        (2..sheet.last_row).filter_map do |row_number|
          attributes = headers.zip(sheet.row(row_number)).to_h
          build_row(row_number, attributes) unless blank_row?(attributes)
        end
      end

      def validate_xlsx_archive!(path)
        Zip::File.open(path) do |archive|
          raise Error, "The XLSX archive contains too many entries." if archive.size > MAX_XLSX_ENTRIES

          uncompressed_size = archive.sum(&:size)
          if uncompressed_size > MAX_XLSX_UNCOMPRESSED_SIZE
            raise Error, "The XLSX archive expands beyond the 25 MB safety limit."
          end
        end
      end

      def reject_oversized_sheet!(sheet)
        return if sheet.last_row.to_i <= MAX_ROWS + 1

        raise Error, "The spreadsheet cannot contain more than #{MAX_ROWS} data rows."
      end

      def normalized_headers(headers)
        headers.map { |header| normalize_header(header) }
      end

      def normalize_header(header)
        header.to_s.strip.downcase.tr(" -", "__").gsub(/_+/, "_")
      end

      def validate_headers!(headers)
        missing = REQUIRED_HEADERS - headers
        return if missing.empty?

        raise Error, "Missing required columns: #{missing.join(', ')}."
      end

      def blank_row?(attributes)
        attributes.values.all? { |value| value.to_s.strip.blank? }
      end

      def build_row(number, attributes)
        allowed = attributes.slice(*(REQUIRED_HEADERS + OPTIONAL_HEADERS))
          .transform_values { |value| value.to_s.strip }

        Row.new(number:, attributes: allowed)
      end
  end
end
