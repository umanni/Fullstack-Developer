require "test_helper"

class UserImportRowTest < ActiveSupport::TestCase
  test "requires a spreadsheet row number and payload" do
    row = UserImportRow.new(user_import: create_user_import, row_number: 1, payload: {})

    assert_not row.valid?
    assert_predicate row.errors[:row_number], :present?
    assert_predicate row.errors[:payload], :present?
  end

  test "row number is unique inside an import" do
    user_import = create_user_import
    user_import.rows.create!(row_number: 2, payload: { email: "one@example.com" })
    duplicate = user_import.rows.new(row_number: 2, payload: { email: "two@example.com" })

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:row_number], "has already been taken"
  end

  test "supports explicit processing states" do
    row = create_user_import.rows.create!(row_number: 2, payload: { email: "one@example.com" })

    assert_predicate row, :pending?
    row.succeeded!
    assert_predicate row, :succeeded?
  end
end
