require "test_helper"

class UserImportTest < ActiveSupport::TestCase
  test "requires a supported spreadsheet" do
    user_import = users(:admin).uploaded_user_imports.new

    assert_not user_import.valid?
    assert_includes user_import.errors[:spreadsheet], "can't be blank"

    attach_spreadsheet(user_import, filename: "users.txt", content_type: "text/plain")
    assert_not user_import.valid?
    assert_includes user_import.errors[:spreadsheet], "must be a CSV or XLSX file"
  end

  test "rejects a mismatched content type" do
    user_import = users(:admin).uploaded_user_imports.new
    attach_spreadsheet(user_import, filename: "users.csv", content_type: "application/pdf")

    assert_not user_import.valid?
    assert_includes user_import.errors[:spreadsheet], "must be a CSV or XLSX file"
  end

  test "calculates bounded progress" do
    user_import = UserImport.new(total_rows: 4, processed_rows: 1)

    assert_equal 25, user_import.progress_percentage
    user_import.total_rows = 0
    assert_equal 0, user_import.progress_percentage
    user_import.total_rows = 1
    user_import.processed_rows = 2
    assert_equal 100, user_import.progress_percentage
  end

  test "refreshes denormalized row counters" do
    user_import = create_user_import
    user_import.update!(total_rows: 3)
    user_import.rows.create!(row_number: 2, payload: { email: "a@example.com" }, status: :succeeded, user: users(:member))
    user_import.rows.create!(row_number: 3, payload: { email: "b@example.com" }, status: :failed, error_message: "Invalid")
    user_import.rows.create!(row_number: 4, payload: { email: "c@example.com" }, status: :pending)

    user_import.refresh_counters!

    assert_equal 2, user_import.processed_rows
    assert_equal 1, user_import.successful_rows
    assert_equal 1, user_import.failed_rows
  end

  test "marks an import failed and streams its status" do
    user_import = create_user_import

    assert_broadcasts ImportProgressChannel.broadcasting_for(user_import), 1 do
      user_import.mark_failed!(StandardError.new("bad spreadsheet"))
    end

    assert_predicate user_import, :failed?
    assert_equal "bad spreadsheet", user_import.failure_message
    assert_predicate user_import.finished_at, :present?
  end
end
