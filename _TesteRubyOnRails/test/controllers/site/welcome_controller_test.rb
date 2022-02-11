require 'test_helper'

class Site::WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get site_welcome_index_url
    assert_response :success
  end

end
