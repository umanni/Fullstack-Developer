require "test_helper"

class RegistrationTest < ActionDispatch::IntegrationTest
  test "visitor registers as normal user and lands on profile" do
    get new_registration_path
    assert_response :success

    assert_difference("User.count", 1) do
      post registration_path, params: { user: { full_name: "Newbie", email: "newbie@example.com", password: "password123", password_confirmation: "password123" } }
    end

    user = User.find_by(email: "newbie@example.com")
    assert user.user?
    assert_redirected_to profile_path
  end

  test "cannot register as admin" do
    post registration_path, params: { user: { full_name: "Evil", email: "evil@example.com", password: "password123", password_confirmation: "password123", role: "admin" } }
    assert User.find_by(email: "evil@example.com").user?
  end
end
