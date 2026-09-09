require "test_helper"

class ControllerQuickCoverageTest < ActionDispatch::IntegrationTest
  test "sessions new" do
    get new_session_path
    assert_response :success
  end

  test "registrations new" do
    get new_registration_path
    assert_response :success
  end

  test "profiles show" do
    user = User.create!(full_name: "Quick", email: "quick@example.com", password: "password123", password_confirmation: "password123")
    sign_in_as(user)
    get profile_path
    assert_response :success
  end

  test "admin dashboard" do
    admin = User.create!(full_name: "Quick Admin", email: "qadmin@example.com", password: "password123", password_confirmation: "password123", role: :admin)
    sign_in_as(admin)
    get admin_root_path
    assert_response :success
  end
end
