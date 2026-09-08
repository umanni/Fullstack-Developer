require "test_helper"

class UserImportPresenterTest < ActiveSupport::TestCase
  test "serializes progress and hides row errors by default" do
    user_import = create_user_import
    user_import.update!(total_rows: 2)
    user_import.rows.create!(row_number: 2, payload: { "email" => "bad@example.com" }, status: :failed, error_message: "Invalid")
    user_import.update!(processed_rows: 1, failed_rows: 1)

    payload = UserImportPresenter.new(user_import).as_json

    assert_equal 50, payload[:progress_percentage]
    assert_equal "users.csv", payload[:file_name]
    assert_empty payload[:row_errors]
  end

  test "optionally exposes bounded row-level errors" do
    user_import = create_user_import
    user_import.update!(total_rows: 1)
    user_import.rows.create!(row_number: 2, payload: { "email" => "bad@example.com" }, status: :failed, error_message: "Invalid email")
    user_import.update!(processed_rows: 1, failed_rows: 1)

    errors = UserImportPresenter.new(user_import, include_errors: true).as_json[:row_errors]

    assert_equal [ { row_number: 2, email: "bad@example.com", message: "Invalid email" } ], errors
  end
end
