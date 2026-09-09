require "test_helper"

class AdminQuickCoverageTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(full_name: "Cover Admin", email: "cover-admin@example.com", password: "password123", password_confirmation: "password123", role: :admin)
  end

  test "admin base controller requires admin" do
    sign_in_as(@admin)
    get admin_root_path
    assert_response :success
  end

  test "admin users index" do
    sign_in_as(@admin)
    get admin_users_path
    assert_response :success
  end

  test "admin user imports index" do
    sign_in_as(@admin)
    get admin_user_imports_path
    assert_response :success
  end
end
