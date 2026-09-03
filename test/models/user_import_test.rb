require "test_helper"

class UserImportTest < ActiveSupport::TestCase
  test "computes bounded progress" do
    user_import = UserImport.new(total_rows: 4, processed_rows: 3)
    assert_equal 75, user_import.progress_percentage

    user_import.processed_rows = 8
    assert_equal 100, user_import.progress_percentage
  end

  test "returns zero progress before rows are discovered" do
    assert_equal 0, UserImport.new.progress_percentage
  end

  test "recognizes terminal states" do
    assert_not UserImport.new(status: :processing).terminal?
    assert UserImport.new(status: :completed_with_errors).terminal?
  end

  test "requires a spreadsheet" do
    user_import = UserImport.new(created_by: users(:admin))
    assert_not user_import.valid?
    assert_includes user_import.errors[:spreadsheet], "can't be blank"
  end

  test "requires a creator when an import is first persisted" do
    user_import = UserImport.new
    user_import.spreadsheet.attach(
      io: File.open(file_fixture("valid_users.csv")), filename: "valid_users.csv", content_type: "text/csv"
    )

    assert_not user_import.save
    assert_includes user_import.errors[:created_by], "can't be blank"
  end

  test "accepts CSV and XLSX spreadsheet attachments" do
    csv_import = build_import("valid_users.csv", "text/csv")
    xlsx_import = build_import(
      "valid_users.xlsx",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

    assert_predicate csv_import, :valid?
    assert_predicate xlsx_import, :valid?
  end

  test "rejects an unsupported spreadsheet extension and content type" do
    user_import = build_import("unsupported.txt", "text/plain")

    assert_not_predicate user_import, :valid?
    assert_includes user_import.errors[:spreadsheet], "must be a CSV or XLSX file"
    assert_includes user_import.errors[:spreadsheet], "content type does not match its extension"
  end

  test "rejects a supported content type paired with the wrong extension" do
    user_import = build_import(
      "valid_users.csv",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

    assert_not_predicate user_import, :valid?
    assert_includes user_import.errors[:spreadsheet], "content type does not match its extension"
  end

  test "rejects oversized spreadsheets" do
    user_import = UserImport.new(created_by: users(:admin))
    user_import.spreadsheet.attach(
      io: StringIO.new("0" * (UserImport::MAX_FILE_SIZE + 1)),
      filename: "users.csv",
      content_type: "text/csv"
    )

    assert_not_predicate user_import, :valid?
    assert_includes user_import.errors[:spreadsheet], "must be smaller than 5 MB"
  end

  private
    def build_import(filename, content_type)
      UserImport.new(created_by: users(:admin), spreadsheet: {
        io: File.open(file_fixture(filename)), filename:, content_type:
      })
    end
end
