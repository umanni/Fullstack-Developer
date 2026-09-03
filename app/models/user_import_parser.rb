require "csv"
require "roo"

# Streams a spreadsheet row by row. Nothing here holds the whole file in
# memory: CSV is read with a streaming reader and XLSX through Roo's streaming
# API, so a large upload costs a constant amount of memory rather than its own
# size.
class UserImportParser
  class UnreadableFile < StandardError; end
  class TooManyRows < StandardError; end

  REQUIRED_HEADERS = %w[full_name email].freeze
  OPTIONAL_HEADERS = %w[avatar_url role].freeze
  HEADERS = (REQUIRED_HEADERS + OPTIONAL_HEADERS).freeze

  # Mirrors the ceiling on UserImport: the parser refuses to walk past it even
  # if it is handed a file directly.
  MAX_ROWS = UserImport::MAX_ROWS

  # Lines starting with this are instructions in the downloadable template, not
  # data, and are skipped wherever they appear.
  COMMENT_PREFIX = "#".freeze

  def initialize(path:, format:)
    @path = path
    @format = format
  end

  def row_count
    count = 0
    each_row { count += 1 }
    count
  end

  # Yields the line number as it appears in the file, so an error report points
  # at the row the operator will actually see in their editor.
  def each_row
    header_map = nil
    yielded = 0

    each_raw_row do |number, values|
      next if skippable?(values)

      if header_map.nil?
        header_map = build_header_map(values)
        next
      end

      yielded += 1
      raise TooManyRows if yielded > MAX_ROWS

      yield number, attributes_from(values, header_map)
    end

    raise UnreadableFile, "no header row found" if header_map.nil?

    yielded
  end

  private

  attr_reader :path, :format

  def each_raw_row(&)
    case format
    when :csv then each_csv_row(&)
    when :xlsx then each_xlsx_row(&)
    else raise UnreadableFile, "unsupported format: #{format.inspect}"
    end
  end

  def each_csv_row
    number = 0

    CSV.foreach(path, encoding: "bom|utf-8") do |values|
      number += 1
      yield number, values
    end
  rescue CSV::MalformedCSVError => e
    raise UnreadableFile, e.message
  end

  def each_xlsx_row
    sheet = Roo::Spreadsheet.open(path, extension: :xlsx)
    number = 0

    sheet.each_row_streaming(pad_cells: true) do |row|
      number += 1
      yield number, row.map { |cell| cell&.value }
    end
  rescue Roo::Error, Zip::Error => e
    raise UnreadableFile, e.message
  end

  def skippable?(values)
    return true if values.nil? || values.compact.empty?

    values.first.to_s.strip.start_with?(COMMENT_PREFIX)
  end

  def build_header_map(values)
    headers = values.map { |value| value.to_s.strip.downcase }
    missing = REQUIRED_HEADERS - headers

    raise UnreadableFile, "missing columns: #{missing.join(", ")}" if missing.any?

    HEADERS.index_with { |header| headers.index(header) }.compact
  end

  def attributes_from(values, header_map)
    {
      full_name: cell(values, header_map["full_name"]),
      email_address: cell(values, header_map["email"])&.downcase,
      avatar_url: cell(values, header_map["avatar_url"]),
      role: cell(values, header_map["role"])&.downcase
    }
  end

  def cell(values, index)
    return if index.nil?

    value = values[index]
    value = value.to_s.strip
    value.presence
  end
end
