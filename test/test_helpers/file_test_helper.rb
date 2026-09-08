require "stringio"
require "cgi"
require "zip"

module FileTestHelper
  VALID_CSV = <<~CSV.freeze
    full_name,email,role
    Katherine Johnson,katherine@example.com,user
    Margaret Hamilton,margaret@example.com,admin
  CSV

  def attach_spreadsheet(user_import, contents: VALID_CSV, filename: "users.csv", content_type: "text/csv")
    user_import.spreadsheet.attach(
      io: StringIO.new(contents),
      filename:,
      content_type:
    )
    user_import
  end

  def create_user_import(contents: VALID_CSV, filename: "users.csv", content_type: "text/csv", uploaded_by: users(:admin))
    user_import = uploaded_by.uploaded_user_imports.new
    attach_spreadsheet(user_import, contents:, filename:, content_type:)
    user_import.save!
    user_import
  end

  def xlsx_contents(rows)
    worksheet_rows = rows.each_with_index.map do |row, row_index|
      cells = row.each_with_index.map do |value, column_index|
        column = (65 + column_index).chr
        escaped = CGI.escapeHTML(value.to_s)
        %(<c r="#{column}#{row_index + 1}" t="inlineStr"><is><t>#{escaped}</t></is></c>)
      end.join
      %(<row r="#{row_index + 1}">#{cells}</row>)
    end.join

    files = {
      "[Content_Types].xml" => <<~XML,
        <?xml version="1.0" encoding="UTF-8"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
          <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
          <Default Extension="xml" ContentType="application/xml"/>
          <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
          <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
        </Types>
      XML
      "_rels/.rels" => <<~XML,
        <?xml version="1.0" encoding="UTF-8"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
        </Relationships>
      XML
      "xl/workbook.xml" => <<~XML,
        <?xml version="1.0" encoding="UTF-8"?>
        <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <sheets><sheet name="Users" sheetId="1" r:id="rId1"/></sheets>
        </workbook>
      XML
      "xl/_rels/workbook.xml.rels" => <<~XML,
        <?xml version="1.0" encoding="UTF-8"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
        </Relationships>
      XML
      "xl/worksheets/sheet1.xml" => <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
          <sheetData>#{worksheet_rows}</sheetData>
        </worksheet>
      XML
    }

    Zip::OutputStream.write_buffer do |archive|
      files.each do |name, contents|
        archive.put_next_entry(name)
        archive.write(contents)
      end
    end.string
  end
end
