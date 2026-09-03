#!/usr/bin/env ruby

require "cgi"
require "csv"
require "fileutils"
require "zip"

ROOT = File.expand_path("..", __dir__)
HEADERS = %w[full_name email avatar_image_url role].freeze
ROWS = [
  [ "Grace Hopper", "grace.hopper@example.com", "https://example.com/grace.jpg", "user" ],
  [ "Katherine Johnson", "katherine.johnson@example.com", "https://example.com/katherine.jpg", "admin" ]
].freeze

def write_csv(path)
  FileUtils.mkdir_p(File.dirname(path))
  CSV.open(path, "wb") do |csv|
    csv << HEADERS
    ROWS.each { |row| csv << row }
  end
end

def cell(reference, value)
  escaped_value = CGI.escapeHTML(value)
  %(<c r="#{reference}" t="inlineStr"><is><t>#{escaped_value}</t></is></c>)
end

def sheet_xml
  rows = [ HEADERS, *ROWS ].each_with_index.map do |values, row_index|
    cells = values.each_with_index.map do |value, column_index|
      reference = "#{('A'.ord + column_index).chr}#{row_index + 1}"
      cell(reference, value)
    end.join
    %(<row r="#{row_index + 1}">#{cells}</row>)
  end.join

  <<~XML
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
      <sheetData>#{rows}</sheetData>
    </worksheet>
  XML
end

def write_xlsx(path)
  FileUtils.mkdir_p(File.dirname(path))
  FileUtils.rm_f(path)

  Zip::File.open(path, create: true) do |zip|
    zip.get_output_stream("[Content_Types].xml") do |file|
      file.write <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
          <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
          <Default Extension="xml" ContentType="application/xml"/>
          <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
          <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
        </Types>
      XML
    end
    zip.get_output_stream("_rels/.rels") do |file|
      file.write <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
        </Relationships>
      XML
    end
    zip.get_output_stream("xl/workbook.xml") do |file|
      file.write <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <sheets><sheet name="Users" sheetId="1" r:id="rId1"/></sheets>
        </workbook>
      XML
    end
    zip.get_output_stream("xl/_rels/workbook.xml.rels") do |file|
      file.write <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
        </Relationships>
      XML
    end
    zip.get_output_stream("xl/worksheets/sheet1.xml") { |file| file.write(sheet_xml) }
  end
end

write_csv(File.join(ROOT, "public/user_import_template.csv"))
write_csv(File.join(ROOT, "test/fixtures/files/valid_users.csv"))
write_xlsx(File.join(ROOT, "public/user_import_template.xlsx"))
write_xlsx(File.join(ROOT, "test/fixtures/files/valid_users.xlsx"))

puts "Generated CSV and XLSX import templates."
