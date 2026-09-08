require "test_helper"

class Admin::UserImportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in_as(@admin)
  end

  test "lists imports" do
    user_import = create_user_import

    get admin_user_imports_path

    assert_response :success
    assert_inertia_component "Admin/Imports/Index"
    assert_equal user_import.id, inertia.props[:imports].first[:id]
  end

  test "renders upload form" do
    get new_admin_user_import_path

    assert_response :success
    assert_inertia_component "Admin/Imports/New"
  end

  test "attaches a spreadsheet and queues processing" do
    upload = Rack::Test::UploadedFile.new(
      Rails.root.join("public/user_import_template.csv"),
      "text/csv"
    )

    assert_difference "UserImport.count", 1 do
      assert_enqueued_with(job: ProcessUserImportJob) do
        post admin_user_imports_path, params: { user_import: { spreadsheet: upload } }
      end
    end

    user_import = UserImport.order(:id).last
    assert_equal @admin, user_import.uploaded_by
    assert_predicate user_import.spreadsheet, :attached?
    assert_redirected_to admin_user_import_path(user_import)
  end

  test "rejects unsupported uploads" do
    upload = Rack::Test::UploadedFile.new(
      Rails.root.join("public/user_import_template.csv"),
      "application/pdf",
      original_filename: "users.pdf"
    )

    assert_no_difference "UserImport.count" do
      post admin_user_imports_path, params: { user_import: { spreadsheet: upload } }
    end

    assert_redirected_to new_admin_user_import_path
  end

  test "shows import details with row errors" do
    user_import = create_user_import
    user_import.update!(total_rows: 1)
    user_import.rows.create!(row_number: 2, payload: { email: "bad@example.com" }, status: :failed, error_message: "Invalid")
    user_import.update!(processed_rows: 1, failed_rows: 1, status: :completed_with_errors)

    get admin_user_import_path(user_import)

    assert_response :success
    assert_inertia_component "Admin/Imports/Show"
    assert_equal 1, inertia.props.dig(:user_import, :row_errors).length
  end

  test "standard users cannot inspect imports" do
    user_import = create_user_import
    sign_out
    sign_in_as(users(:member))

    get admin_user_import_path(user_import)

    assert_redirected_to profile_path
  end
end
