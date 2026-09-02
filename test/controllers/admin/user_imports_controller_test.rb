require "test_helper"

class Admin::UserImportsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup { sign_in_as(users(:admin)) }

  test "lists imports and renders the upload form" do
    get admin_user_imports_path
    assert_response :success

    get new_admin_user_import_path
    assert_response :success
    assert_select "input[type=file][accept]"
  end

  test "queues a valid CSV import" do
    spreadsheet = fixture_file_upload("valid_users.csv", "text/csv")

    assert_enqueued_with(job: Imports::ProcessJob) do
      assert_difference "UserImport.count", 1 do
        post admin_user_imports_path, params: { user_import: { spreadsheet: } }
      end
    end

    assert_redirected_to admin_user_import_path(UserImport.last)
  end

  test "accepts a valid XLSX import" do
    spreadsheet = fixture_file_upload(
      "valid_users.xlsx",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

    assert_difference "UserImport.count", 1 do
      post admin_user_imports_path, params: { user_import: { spreadsheet: } }
    end

    assert_redirected_to admin_user_import_path(UserImport.last)
  end

  test "rejects an unsupported upload" do
    spreadsheet = fixture_file_upload("unsupported.txt", "text/plain")

    assert_no_difference "UserImport.count" do
      post admin_user_imports_path, params: { user_import: { spreadsheet: } }
    end

    assert_response :unprocessable_entity
    assert_select "[role=alert]"
  end

  test "shows durable progress and row failures" do
    user_import = create_import
    user_import.update!(status: :completed_with_errors, total_rows: 1, processed_rows: 1, failed_rows: 1)
    user_import.rows.create!(row_number: 2, payload: { "email" => "bad@example.com" }, status: :failed,
      error_message: "Email is invalid")

    get admin_user_import_path(user_import)

    assert_response :success
    assert_select "progress[value='100']"
    assert_match "Email is invalid", response.body
  end

  test "does not expose imports to a standard user" do
    sign_out
    sign_in_as(users(:member))

    get admin_user_imports_path

    assert_redirected_to profile_path
  end

  private
    def create_import
      UserImport.create!(created_by: users(:admin), spreadsheet: {
        io: StringIO.new("placeholder"), filename: "users.csv", content_type: "text/csv"
      })
    end
end
