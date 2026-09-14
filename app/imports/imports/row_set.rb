module Imports
  class RowSet
    include Enumerable

    class MalformedFile < StandardError; end

    def self.for(import, path)
      case import.format
      when :xlsx then SpreadsheetRowSet.new(path)
      else CsvRowSet.new(path)
      end
    end

    def initialize(path)
      @path = path
    end

    def count = @count ||= each.count
  end
end
