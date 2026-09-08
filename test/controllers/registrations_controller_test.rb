require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "renders visitor registration" do
    get new_registration_path

    assert_response :success
    assert_inertia_component "Auth/Register"
  end

  test "registers and signs in a standard user" do
    assert_difference [ "User.count", "Session.count" ], 1 do
      post registration_path, params: {
        user: {
          full_name: "Visitor User",
          email: "visitor@example.com",
          password: "StrongPassword!123",
          password_confirmation: "StrongPassword!123",
          role: "admin"
        }
      }
    end

    assert_redirected_to profile_path
    assert_predicate User.find_by!(email: "visitor@example.com"), :user?
    assert cookies[:session_id]
  end

  test "returns validation errors without creating a user" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: { full_name: "", email: "bad", password: "short", password_confirmation: "short" }
      }
    end

    assert_redirected_to new_registration_path
  end

  test "redirects authenticated users away from registration" do
    sign_in_as(users(:member))

    get new_registration_path

    assert_redirected_to profile_url
  end
end
