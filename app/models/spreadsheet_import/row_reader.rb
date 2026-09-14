class SpreadsheetImport
  # Roo picks its parser from the extension, and an Active Storage file has no useful
  # suffix. Read by index because `each_row_streaming` is xlsx-only.
  class RowReader
    COLUMNS = %i[ full_name email role ].freeze
    HEADER_ROW = 1

    def initialize(path, extension:)
      @sheet = Roo::Spreadsheet.open(path.to_s, extension: extension.to_sym)
    end

    # Counted by walking the rows rather than trusting last_row: spreadsheets saved from
    # Excel routinely carry trailing empty rows, and counting those makes every one of
    # them a phantom rejected row and the progress bar wrong.
    def row_count
      count = 0
      each_row { count += 1 }
      count
    end

    def each_row
      header = normalized_header
      # A file exported with ";" separators parses as one column, and one without an
      # email column imports nothing. Either would otherwise report a successful 0 of 0.
      unless header.include?(:email)
        raise ArgumentError, "the file has no `email` column (found: #{header.join(", ")})"
      end

      ((HEADER_ROW + 1)..@sheet.last_row.to_i).each do |line|
        attributes = attributes_from(header, @sheet.row(line))
        next if attributes.values.all?(&:blank?)

        yield attributes, line
      end
    end

    private
      def normalized_header
        @sheet.row(HEADER_ROW).map { |cell| cell.to_s.strip.downcase.tr(" ", "_").to_sym }
      end

      def attributes_from(header, cells)
        attributes = header.zip(cells.map { |cell| cell.to_s.strip.presence }).to_h.slice(*COLUMNS)
        attributes[:role] = attributes[:role]&.downcase
        attributes
      end
  end
end
