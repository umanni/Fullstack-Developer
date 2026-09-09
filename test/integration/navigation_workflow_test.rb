require "test_helper"

class NavigationWorkflowTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(full_name: "Admin", email: "nav-admin@example.com", password: "password123", password_confirmation: "password123", role: :admin)
    @user = User.create!(full_name: "Nav User", email: "nav-user@example.com", password: "password123", password_confirmation: "password123")
  end

  test "root redirects admin to dashboard and user to profile" do
    sign_in_as(@admin)
    get root_path
    assert_redirected_to admin_root_path
    sign_in_as(@user)
    get root_path
    assert_redirected_to profile_path
  end

  test "layout nav exposes workflows" do
    get new_session_path
    assert_response :success
    assert_match "Sign up", response.body
    assert_match "Forgot password", response.body

    sign_in_as(@user)
    get profile_path
    assert_match "Edit", response.body
    assert_match "Delete", response.body
    assert_match "Sign out", response.body

    sign_in_as(@admin)
    get admin_root_path
    assert_match "Users", response.body
    assert_match "Imports", response.body
    get admin_users_path
    assert_match "New user", response.body
  end
end
