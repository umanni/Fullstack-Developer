require "test_helper"

class Admin::SpreadsheetImportsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "lists imports newest first" do
    older = create_import
    older.update!(created_at: 1.hour.ago)
    newer = create_import

    get admin_spreadsheet_imports_path

    assert_response :success
    assert_operator response.body.index(admin_spreadsheet_import_path(newer)),
                    :<, response.body.index(admin_spreadsheet_import_path(older))
  end

  test "renders the upload form" do
    get new_admin_spreadsheet_import_path

    assert_response :success
    assert_select "input[type=submit][data-turbo-submits-with=?]", "Uploading…"
  end

  test "queues the import and sends the admin to its progress page" do
    assert_difference -> { SpreadsheetImport.count }, 1 do
      assert_enqueued_with job: SpreadsheetImportJob do
        post admin_spreadsheet_imports_path, params: { spreadsheet_import: { file: csv_upload } }
      end
    end

    assert_redirected_to admin_spreadsheet_import_path(SpreadsheetImport.last)
    assert_predicate SpreadsheetImport.last, :pending?
  end

  test "records who started the import" do
    post admin_spreadsheet_imports_path, params: { spreadsheet_import: { file: csv_upload } }

    assert_equal users(:admin), SpreadsheetImport.last.user
  end

  test "refuses a file that is not a spreadsheet" do
    assert_no_difference -> { SpreadsheetImport.count } do
      assert_no_enqueued_jobs only: SpreadsheetImportJob do
        post admin_spreadsheet_imports_path, params: {
          spreadsheet_import: { file: fixture_file_upload("not-an-image.txt", "text/plain") }
        }
      end
    end

    assert_response :unprocessable_content
  end

  test "rejects a submission that is not nested under a spreadsheet_import key" do
    post admin_spreadsheet_imports_path, params: { file: csv_upload }

    assert_response :bad_request
  end

  test "shows an import and subscribes to its stream" do
    get admin_spreadsheet_import_path(create_import)

    assert_response :success
    assert_select "turbo-cable-stream-source"
  end

  test "is closed to users who are not admins" do
    sign_out
    sign_in_as users(:member)

    get admin_spreadsheet_imports_path

    assert_redirected_to profile_url
  end

  private
    def csv_upload
      fixture_file_upload("users.csv", "text/csv")
    end

    def create_import
      users(:admin).spreadsheet_imports.create!(
        file: { io: file_fixture("users.csv").open, filename: "users.csv" }
      )
    end
end
