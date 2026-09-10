require "test_helper"

class AdminImportsExtraTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(full_name: "Imports Admin", email: "imports-extra-admin@example.com", password: "password123", password_confirmation: "password123", role: :admin)
    sign_in_as(@admin)
  end

  test "lists imports with file names" do
    import = UserImport.new(status: :pending, total_rows: 0, processed_rows: 0, failed_rows: 0)
    import.file.attach(io: StringIO.new("full_name,email,password\n"), filename: "XXX_USERS_.csv", content_type: "text/csv")
    import.save!

    get admin_user_imports_path
    assert_response :success
    assert_match "XXX_USERS_.csv", response.body
  end

  test "create without file rerenders form" do
    post admin_user_imports_path, params: { user_import: { file: nil } }
    assert_response :unprocessable_entity
    assert_match "Admin/Imports/New", response.body
  end
end
