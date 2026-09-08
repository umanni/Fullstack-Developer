require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "visitor goes to sign in" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "admin goes to dashboard" do
    sign_in_as(users(:admin))
    get root_path
    assert_redirected_to admin_root_path
  end

  test "standard user goes to profile" do
    sign_in_as(users(:member))
    get root_path
    assert_redirected_to profile_path
  end
end
