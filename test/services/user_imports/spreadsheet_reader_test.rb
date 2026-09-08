require "test_helper"

class UserImports::SpreadsheetReaderTest < ActiveSupport::TestCase
  test "normalizes CSV headers and values" do
    csv = <<~CSV
      Full Name,Email,Role
      "  Mary   Jackson  ", MARY@EXAMPLE.COM ,no-admin
    CSV
    user_import = create_user_import(contents: csv)

    row_number, payload = UserImports::SpreadsheetReader.new(user_import).each_row.first

    assert_equal 2, row_number
    assert_equal "Mary Jackson", payload["full_name"]
    assert_equal "mary@example.com", payload["email"]
    assert_equal "user", payload["role"]
  end

  test "reads XLSX workbooks" do
    workbook = xlsx_contents([
      %w[full_name email role],
      [ "Annie Easley", "ANNIE@example.com", "admin" ]
    ])
    user_import = create_user_import(
      contents: workbook,
      filename: "users.xlsx",
      content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

    _, payload = UserImports::SpreadsheetReader.new(user_import).each_row.first

    assert_equal "Annie Easley", payload["full_name"]
    assert_equal "annie@example.com", payload["email"]
    assert_equal "admin", payload["role"]
  end

  test "rejects spreadsheets without required columns" do
    user_import = create_user_import(contents: "name,role\nMissing Email,user\n")

    error = assert_raises(UserImports::SpreadsheetReader::Error) do
      UserImports::SpreadsheetReader.new(user_import).each_row.to_a
    end

    assert_match(/full_name, email/, error.message)
  end

  test "ignores blank rows and defaults an empty role" do
    csv = "full_name,email,role\n\nBarbara Liskov,barbara@example.com,\n"
    user_import = create_user_import(contents: csv)

    rows = UserImports::SpreadsheetReader.new(user_import).each_row.to_a

    assert_equal 1, rows.length
    assert_equal "user", rows.first.last["role"]
  end

  test "limits spreadsheet size by row count" do
    csv = "full_name,email\n" + 5_001.times.map { |index| "User #{index},user#{index}@example.com" }.join("\n")
    user_import = create_user_import(contents: csv)

    error = assert_raises(UserImports::SpreadsheetReader::Error) do
      UserImports::SpreadsheetReader.new(user_import).each_row.to_a
    end

    assert_match(/5,000 rows/, error.message)
  end
end
