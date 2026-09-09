require "test_helper"
class QuickAdminTest < ActionDispatch::IntegrationTest
  test "admin import new" do
    admin = User.create!(full_name: "Quick", email: "quick2@example.com", password: "password123", password_confirmation: "password123", role: :admin)
    sign_in_as(admin)
    get new_admin_user_import_path
    assert_response :success
  end
end
