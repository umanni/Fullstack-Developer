# frozen_string_literal: true

module UserImports
  # Parser boundary contract: normalized headers plus a lazy, re-readable
  # row stream and its total count. The parser does not touch the domain.
  class Result
    def initialize(headers:, rows:, total_rows:)
      @headers = headers.freeze
      @rows = rows
      @total_rows = total_rows
      freeze
    end

    attr_reader :headers, :rows, :total_rows
  end
end
