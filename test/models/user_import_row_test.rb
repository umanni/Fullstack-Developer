require "test_helper"

class UserImportRowTest < ActiveSupport::TestCase
  test "requires a physical spreadsheet row number" do
    row = UserImportRow.new(row_number: 1, payload: { "email" => "test@example.com" })
    assert_not row.valid?
    assert_includes row.errors[:row_number], "must be greater than or equal to 2"
  end
end
