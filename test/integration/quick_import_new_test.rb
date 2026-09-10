require "test_helper"
class QuickImportTest < ActionDispatch::IntegrationTest
  setup { @admin = User.create!(full_name: "Imp", email: "imp@example.com", password: "Password123", password_confirmation: "Password123", role: :admin) }
  test "new" do
    sign_in_as(@admin)
    get new_admin_user_import_path
    assert_response :success
  end
end
