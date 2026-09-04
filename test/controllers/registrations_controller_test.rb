require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "visitor can register as member" do
    assert_difference("User.count", 1) do
      post registration_url, params: {
        user: {
          full_name: "New Visitor",
          email_address: "visitor@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to profile_url
    assert User.find_by(email_address: "visitor@example.com").member?
  end

  test "rejects invalid registration" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: { full_name: "", email_address: "bad", password: "short" }
      }
    end
    assert_response :unprocessable_entity
  end
end
