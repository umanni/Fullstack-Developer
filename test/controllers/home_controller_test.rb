require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "visitor sees landing page" do
    get root_url
    assert_response :success
    assert_match "Umanni Users", response.body
  end

  test "admin is redirected to dashboard" do
    sign_in_as users(:admin)
    get root_url
    assert_redirected_to admin_root_path
  end

  test "member is redirected to profile" do
    sign_in_as users(:member)
    get root_url
    assert_redirected_to profile_path
  end
end
