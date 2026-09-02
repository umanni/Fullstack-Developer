require "test_helper"

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

    assert_match "could not be parsed", error.message
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
