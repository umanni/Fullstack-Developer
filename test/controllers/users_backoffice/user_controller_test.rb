require 'test_helper'

class UsersBackoffice::UserControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get users_backoffice_user_show_url
    assert_response :success
  end

end
