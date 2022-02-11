require 'test_helper'

class UsersBackoffice::UserControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_backoffice_user_index_url
    assert_response :success
  end

end
