require 'test_helper'

class UsersBackoffice::AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get destroy" do
    get users_backoffice_admin_destroy_url
    assert_response :success
  end

end
