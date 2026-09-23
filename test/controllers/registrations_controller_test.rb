require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "visitor can register as non-admin" do
    assert_difference("User.count", 1) do
      post registration_url, params: {
        user: {
          full_name: "New Visitor",
          email: "visitor@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    user = User.find_by!(email: "visitor@example.com")
    assert_not user.admin?
    assert_redirected_to profile_url
  end
end
