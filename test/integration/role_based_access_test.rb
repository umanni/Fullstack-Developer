require "test_helper"

class RoleBasedAccessTest < ActionDispatch::IntegrationTest
  test "an admin lands on the dashboard after signing in" do
    sign_in users(:admin)

    assert_redirected_to admin_dashboard_path
  end

  test "a user lands on their profile after signing in" do
    sign_in users(:member)

    assert_redirected_to profile_path
  end

  test "the root path sends each role to their own home" do
    sign_in_as users(:admin)
    get root_path

    assert_redirected_to admin_dashboard_path

    sign_out
    sign_in_as users(:member)
    get root_path

    assert_redirected_to profile_path
  end

  test "a user cannot reach an admin screen" do
    sign_in_as users(:member)

    get admin_dashboard_path

    assert_redirected_to profile_path
    assert_equal "You are not authorised to access that page.", flash[:alert]
  end

  test "a visitor is sent to sign in and returned to where they were headed" do
    get admin_dashboard_path

    assert_redirected_to new_session_path

    sign_in users(:admin)

    assert_redirected_to admin_dashboard_url
  end

  private
    def sign_in(user)
      post session_path, params: { session: { email: user.email, password: "secret-password" } }
    end
end
