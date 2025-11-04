require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get pages_home_url
    assert_response :success
  end

  test "should get users" do
    get pages_users_url
    assert_response :success
  end

  test "should get admin" do
    get pages_admin_url
    assert_response :success
  end
end
