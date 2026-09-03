require "test_helper"
require "tempfile"

class Imports::SpreadsheetParserTest < ActiveSupport::TestCase
  test "parses CSV headers and rows" do
    rows = Imports::SpreadsheetParser.call(import_with_fixture("valid_users.csv", "text/csv"))

    assert_equal 2, rows.length
    assert_equal 2, rows.first.number
    assert_equal "Grace Hopper", rows.first.attributes.fetch("full_name")
    assert_equal "user", rows.first.attributes.fetch("role")
  end

  test "parses a real XLSX workbook" do
    rows = Imports::SpreadsheetParser.call(import_with_fixture(
      "valid_users.xlsx",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    ))

    assert_equal 2, rows.length
    assert_equal "katherine.johnson@example.com", rows.second.attributes.fetch("email")
  end

  test "normalizes friendly header names and ignores blank rows" do
    csv = <<~CSV
      Full Name,Email,Avatar Image URL,Role
      Ada Example,ada-new@example.com,https://example.com/ada.png,admin
      ,,,
    CSV

    rows = Imports::SpreadsheetParser.call(import_with_csv(csv))

    assert_equal 1, rows.length
    assert_equal "Ada Example", rows.first.attributes.fetch("full_name")
  end

  test "rejects missing required columns" do
    error = assert_raises(Imports::SpreadsheetParser::Error) do
      Imports::SpreadsheetParser.call(import_with_csv("full_name,email\nAda,ada@example.com\n"))
    end

    assert_match "Missing required columns: avatar_image_url", error.message
  end

  test "rejects empty spreadsheets" do
    error = assert_raises(Imports::SpreadsheetParser::Error) do
      Imports::SpreadsheetParser.call(import_with_csv("full_name,email,avatar_image_url,role\n"))
    end

    assert_match "at least one data row", error.message
  end

  test "rejects malformed CSV" do
    error = assert_raises(Imports::SpreadsheetParser::Error) do
      Imports::SpreadsheetParser.call(import_with_csv("full_name,email,avatar_image_url\n\"unterminated"))
    end

    assert_equal "The spreadsheet could not be parsed. Verify the file format and try again.", error.message
  end

  test "rejects a sparse XLSX sheet before iterating an unbounded row range" do
    sheet = Struct.new(:last_row).new(Imports::SpreadsheetParser::MAX_ROWS + 2)
    parser = Imports::SpreadsheetParser.new(import_with_fixture(
      "valid_users.xlsx",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    ))

    error = assert_raises(Imports::SpreadsheetParser::Error) do
      parser.send(:reject_oversized_sheet!, sheet)
    end

    assert_match "cannot contain more than 1000", error.message
  end

  test "rejects an XLSX archive with an excessive expanded size" do
    parser = Imports::SpreadsheetParser.new(import_with_fixture(
      "valid_users.xlsx",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    ))

    Tempfile.create([ "oversized", ".xlsx" ]) do |file|
      Zip::OutputStream.open(file.path) do |archive|
        archive.put_next_entry("xl/oversized.xml")
        chunk = "0" * 1.megabyte
        26.times { archive.write(chunk) }
      end

      error = assert_raises(Imports::SpreadsheetParser::Error) do
        parser.send(:validate_xlsx_archive!, file.path)
      end

      assert_match "expands beyond the 25 MB safety limit", error.message
    end
  end

  private
    def import_with_fixture(filename, content_type)
      user_import = UserImport.create!(created_by: users(:admin), spreadsheet: {
        io: File.open(file_fixture(filename)), filename:, content_type:
      })
      user_import
    end

    def import_with_csv(contents)
      UserImport.create!(created_by: users(:admin), spreadsheet: {
        io: StringIO.new(contents), filename: "users.csv", content_type: "text/csv"
      })
    end
end
