require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "renders registration for a visitor" do
    get new_registration_path

    assert_response :success
    assert_select "h1", "Create your user profile"
  end

  test "registers, signs in, and forces the standard user role" do
    attributes = valid_user_attributes(email: "visitor@example.com").merge(role: :admin)

    assert_difference [ "User.count", "Session.count" ], 1 do
      post registration_path, params: { user: attributes }
    end

    user = User.find_by!(email: "visitor@example.com")
    assert_predicate user, :user?
    assert_redirected_to profile_path
  end

  test "renders validation feedback without creating an account" do
    assert_no_difference "User.count" do
      post registration_path, params: { user: valid_user_attributes(email: "invalid") }
    end

    assert_response :unprocessable_entity
    assert_select "[role=alert]", /Email/
  end

  test "redirects an authenticated user away from registration" do
    sign_in_as(users(:member))

    get new_registration_path

    assert_redirected_to profile_path
  end

  test "redirects an authenticated administrator to the dashboard" do
    sign_in_as(users(:admin))

    get new_registration_path

    assert_redirected_to admin_root_path
  end
end
