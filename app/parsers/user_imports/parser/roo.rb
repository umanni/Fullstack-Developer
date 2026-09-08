# frozen_string_literal: true

module UserImports
  class Parser
    # Roo backs every extension in the registry (csv/xlsx/xls). It reads the
    # first sheet, normalizes headers (case/underscore) onto the canonical
    # form attributes, skips the header row and blank lines, and exposes the
    # remaining rows lazily (Enumerator#lazy over the sheet).
    # Substitutable implementation of the UserImports::Parser interface (LSP).
    class Roo
      # Canonical attribute key after header normalization.
      HEADER_MAP = {
        "full_name" => :full_name,
        "fullname" => :full_name,
        "full name" => :full_name,
        "email_address" => :email_address,
        "emailaddress" => :email_address,
        "email" => :email_address,
        "e-mail" => :email_address,
        "e_mail" => :email_address,
        "avatar_url" => :avatar_url,
        "avatar url" => :avatar_url,
        "avatar" => :avatar_url
      }.freeze

      CSV_OPTIONS = { col_sep: ",", encoding: "BOM|UTF-8" }.freeze

      # uploaded_file is either an ActiveStorage attachment (responds to
      # #download) or a path String/Pathname — normalized the same way.
      def parse(uploaded_file)
        with_source(uploaded_file) do |path, extension|
          spreadsheet = ::Roo::Spreadsheet.open(path, extension: extension, csv_options: CSV_OPTIONS)
          rows_from(spreadsheet)
        end
      end

      private

      def with_source(uploaded_file)
        extension = extension_for(uploaded_file)
        if uploaded_file.respond_to?(:download)
          Tempfile.create([ "user_import", extension ]) do |file|
            file.binmode
            file.write(uploaded_file.download)
            file.rewind
            yield file.path, extension.delete(".").to_sym
          end
        else
          yield uploaded_file.to_s, extension.delete(".").to_sym
        end
      end

      def extension_for(uploaded_file)
        name =
          if uploaded_file.respond_to?(:filename)
            uploaded_file.filename.to_s
          else
            uploaded_file.to_s
          end
        File.extname(name).downcase
      end

      def rows_from(spreadsheet)
        sheet = spreadsheet.sheet(0)
        map = header_map(sheet.row(1))
        data_rows = data_rows_of(sheet)

        rows = data_rows.lazy.map do |row_number, cells|
          Row.new(row_number: row_number, attributes: attributes_for(cells, map))
        end

        Result.new(headers: map.keys, rows: rows, total_rows: data_rows.size)
      end

      def header_map(header_row)
        header_row.to_a.each_with_index.each_with_object({}) do |(cell, index), map|
          key = HEADER_MAP[normalize_header(cell)]
          map[key] = index if key
        end
      end

      # Lazily consumed list of [original_row_number, cells] for non-blank
      # data rows (line 1 is the header). Range is bounded by sheet.last_row.
      def data_rows_of(sheet)
        (2..sheet.last_row).filter_map do |row_number|
          cells = sheet.row(row_number)
          next if blank_row?(cells)

          [ row_number, cells ]
        end
      end

      def attributes_for(cells, map)
        map.each_with_object({}) do |(key, index), attributes|
          attributes[key] = normalize_value(cells[index])
        end
      end

      def blank_row?(cells)
        cells.nil? || cells.all? { |cell| cell.nil? || cell.to_s.strip.empty? }
      end

      def normalize_header(cell)
        return "" if cell.nil?

        cell.to_s.strip.downcase.gsub(/[\s\-]+/, "_")
      end

      def normalize_value(cell)
        return nil if cell.nil?

        cell.to_s.strip
      end
    end
  end
end
