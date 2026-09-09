require "test_helper"
class QuickControllerTest < ActionDispatch::IntegrationTest
  test "home" do
    get root_path
    assert [ 200, 302 ].include?(response.status)
  end
end
