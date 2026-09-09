require "test_helper"

class LoginRedirectTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(full_name: "Admin", email: "admin2@example.com", password: "password123", password_confirmation: "password123", role: :admin)
    @user = User.create!(full_name: "Regular", email: "user2@example.com", password: "password123", password_confirmation: "password123", role: :user)
  end

  test "admin redirected to admin dashboard after login" do
    post session_path, params: { email: @admin.email, password: "password123" }
    assert_redirected_to admin_root_path
  end

  test "user redirected to profile after login" do
    post session_path, params: { email: @user.email, password: "password123" }
    assert_redirected_to profile_path
  end
end
