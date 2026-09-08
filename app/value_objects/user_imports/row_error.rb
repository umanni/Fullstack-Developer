# frozen_string_literal: true

module UserImports
  # A typed validation error for a single attribute of a single row.
  # Only {row_number, attribute, message} — never the whole row data
  # (privacy + typing).
  class RowError
    def initialize(row_number:, attribute:, message:)
      @row_number = row_number
      @attribute = attribute
      @message = message
      freeze
    end

    attr_reader :row_number, :attribute, :message
  end
end
