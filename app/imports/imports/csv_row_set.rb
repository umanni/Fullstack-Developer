module Imports
  class CsvRowSet < RowSet
    def each
      return enum_for(:each) unless block_given?

      headers = nil
      index   = 0

      CSV.foreach(@path, encoding: "bom|utf-8", liberal_parsing: true) do |values|
        if headers.nil?
          headers = UserRow.normalize_headers(values)
          raise MalformedFile, "No recognisable columns found" if headers.compact.empty?
          next
        end

        next if values.all?(&:blank?)

        index += 1
        yield index, UserRow.from(headers, values)
      end
    rescue CSV::MalformedCSVError => error
      raise MalformedFile, error.message
    end
  end
end
