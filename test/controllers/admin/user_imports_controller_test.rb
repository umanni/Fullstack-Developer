require "test_helper"

class Admin::UserImportsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_user_imports_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_user_imports_create_url
    assert_response :success
  end

  test "should get show" do
    get admin_user_imports_show_url
    assert_response :success
  end
end
