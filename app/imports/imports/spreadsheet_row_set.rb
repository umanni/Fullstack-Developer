module Imports
  class SpreadsheetRowSet < RowSet
    def each
      return enum_for(:each) unless block_given?

      sheet   = Roo::Excelx.new(@path)
      headers = nil
      index   = 0

      sheet.each_row_streaming(pad_cells: true) do |row|
        values = row.map { _1&.value }

        if headers.nil?
          headers = UserRow.normalize_headers(values)
          raise MalformedFile, "No recognisable columns found" if headers.compact.empty?
          next
        end

        next if values.all?(&:blank?)

        index += 1
        yield index, UserRow.from(headers, values)
      end
    rescue Roo::Error, Zip::Error => error
      raise MalformedFile, error.message
    end
  end
end
