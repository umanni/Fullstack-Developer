# Parses a SpreadsheetImport's attached CSV/XLSX file into (row_number, data) pairs.
#
# Spreadsheet data is untrusted external input: every cell is treated as plain
# data (never evaluated or interpreted). Column mapping is always positional (1st
# column is the full name, 2nd is the email) — a header row's own text, if present,
# is never read to decide the mapping; when has_header? is true, that row is simply
# skipped, never parsed as data.
class SpreadsheetParser
  class ParseError < StandardError; end

  def initialize(spreadsheet_import)
    @spreadsheet_import = spreadsheet_import
  end

  def rows
    spreadsheet_import.file.open do |tempfile|
      sheet = Roo::Spreadsheet.open(tempfile.path, extension: extension).sheet(0)
      first_data_row = spreadsheet_import.has_header? ? 2 : 1

      (first_data_row..sheet.last_row).filter_map do |row_number|
        values = sheet.row(row_number)
        next if values.all? { |value| value.to_s.strip.blank? }
        [ row_number, { "nome" => values[0].to_s.strip, "email" => values[1].to_s.strip } ]
      end
    end
  rescue => e
    raise ParseError, e.message
  end

  private

  attr_reader :spreadsheet_import

  def extension
    File.extname(spreadsheet_import.file.filename.to_s).delete(".").downcase.to_sym
  end
end
