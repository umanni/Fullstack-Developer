require "test_helper"

class AdminDashboardTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(full_name: "Admin", email: "admin@example.com", password: "Password123", password_confirmation: "Password123", role: :admin)
    @user = User.create!(full_name: "Regular", email: "user@example.com", password: "Password123", password_confirmation: "Password123", role: :user)
  end

  test "admin dashboard shows total and by role" do
    sign_in_as(@admin)
    get admin_root_path
    assert_response :success
    assert_match "Admin/Dashboard/Show", response.body
    assert_match "total_users", response.body
    assert_match "users_by_role", response.body
    assert_match "admin", response.body
    assert_match "user", response.body
  end

  test "non-admin redirected" do
    sign_in_as(@user)
    get admin_root_path
    assert_redirected_to root_path
  end
end
