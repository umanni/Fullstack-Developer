# frozen_string_literal: true

module UserImports
  # One normalized spreadsheet row crossing the parser boundary.
  # The parser never validates domain rules (SRP): a Row only transports
  # data, tagged with its original spreadsheet line number.
  class Row
    def initialize(row_number:, attributes:)
      @row_number = row_number
      @attributes = attributes.freeze
      freeze
    end

    attr_reader :row_number, :attributes
  end
end
