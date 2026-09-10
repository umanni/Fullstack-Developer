require "test_helper"
class QuickAdminImportPathTest < ActionDispatch::IntegrationTest
  setup { @admin = User.create!(full_name: "Imp", email: "imp2@example.com", password: "Password123", password_confirmation: "Password123", role: :admin) }
  test "new import path" do
    sign_in_as(@admin)
    get new_admin_user_import_path
    assert_response :success
  end
end
