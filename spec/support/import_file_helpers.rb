require "zip"

# Throwaway CSV and xlsx files for the import row sets. The bundle has no xlsx
# writer, and a checked-in binary fixture would hide what each example feeds
# the parser, so workbooks are assembled from the minimum OOXML parts Roo needs
# to read a single sheet.
module ImportFileHelpers
  SPREADSHEETML = "http://schemas.openxmlformats.org/spreadsheetml/2006/main".freeze
  RELATIONSHIPS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships".freeze
  PACKAGE       = "http://schemas.openxmlformats.org/package/2006/relationships".freeze
  CONTENT_TYPES = "http://schemas.openxmlformats.org/package/2006/content-types".freeze
  OOXML_TYPE    = "application/vnd.openxmlformats-officedocument.spreadsheetml".freeze

  # Written as raw bytes so examples can hand in text in any encoding.
  def csv_file(content, name: "users.csv")
    import_file_path(name).tap { |path| File.binwrite(path, content) }
  end

  # Each row is an array of cell values: strings, numbers, or nil for a cell
  # that is absent from the sheet entirely.
  def xlsx_file(rows, name: "users.xlsx")
    import_file_path(name).tap do |path|
      Zip::OutputStream.open(path) do |zip|
        xlsx_parts(rows).each do |entry, xml|
          zip.put_next_entry(entry)
          zip.write(xml)
        end
      end
    end
  end

  private

  def import_file_path(name)
    @import_file_dir ||= Dir.mktmpdir("import-files")
    File.join(@import_file_dir, name)
  end

  def xlsx_parts(rows)
    {
      "[Content_Types].xml" => <<~XML,
        <?xml version="1.0" encoding="UTF-8"?>
        <Types xmlns="#{CONTENT_TYPES}">
          <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
          <Default Extension="xml" ContentType="application/xml"/>
          <Override PartName="/xl/workbook.xml" ContentType="#{OOXML_TYPE}.sheet.main+xml"/>
          <Override PartName="/xl/worksheets/sheet1.xml" ContentType="#{OOXML_TYPE}.worksheet+xml"/>
          <Override PartName="/xl/styles.xml" ContentType="#{OOXML_TYPE}.styles+xml"/>
        </Types>
      XML
      "_rels/.rels" => <<~XML,
        <?xml version="1.0" encoding="UTF-8"?>
        <Relationships xmlns="#{PACKAGE}">
          <Relationship Id="rId1" Type="#{RELATIONSHIPS}/officeDocument" Target="xl/workbook.xml"/>
        </Relationships>
      XML
      "xl/workbook.xml" => <<~XML,
        <?xml version="1.0" encoding="UTF-8"?>
        <workbook xmlns="#{SPREADSHEETML}" xmlns:r="#{RELATIONSHIPS}">
          <sheets><sheet name="Sheet1" sheetId="1" r:id="rId1"/></sheets>
        </workbook>
      XML
      "xl/_rels/workbook.xml.rels" => <<~XML,
        <?xml version="1.0" encoding="UTF-8"?>
        <Relationships xmlns="#{PACKAGE}">
          <Relationship Id="rId1" Type="#{RELATIONSHIPS}/worksheet" Target="worksheets/sheet1.xml"/>
          <Relationship Id="rId2" Type="#{RELATIONSHIPS}/styles" Target="styles.xml"/>
        </Relationships>
      XML
      "xl/styles.xml" => <<~XML,
        <?xml version="1.0" encoding="UTF-8"?>
        <styleSheet xmlns="#{SPREADSHEETML}"><cellXfs count="1"><xf numFmtId="0"/></cellXfs></styleSheet>
      XML
      "xl/worksheets/sheet1.xml" => <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <worksheet xmlns="#{SPREADSHEETML}"><sheetData>#{xlsx_rows(rows)}</sheetData></worksheet>
      XML
    }
  end

  def xlsx_rows(rows)
    rows.each_with_index.map do |values, row_index|
      cells = values.each_with_index.map { |value, column| xlsx_cell("#{xlsx_column(column)}#{row_index + 1}", value) }
      %(<row r="#{row_index + 1}">#{cells.join}</row>)
    end.join
  end

  def xlsx_cell(ref, value)
    case value
    when nil     then ""
    when Numeric then %(<c r="#{ref}"><v>#{value}</v></c>)
    else %(<c r="#{ref}" t="inlineStr"><is><t>#{value.to_s.encode(xml: :text)}</t></is></c>)
    end
  end

  def xlsx_column(index)
    return ("A".ord + index).chr if index < 26

    xlsx_column(index / 26 - 1) + xlsx_column(index % 26)
  end
end

RSpec.configure do |config|
  config.include ImportFileHelpers, file_path: %r{spec/imports/}

  config.after(file_path: %r{spec/imports/}) do
    FileUtils.remove_entry(@import_file_dir) if @import_file_dir
  end
end
