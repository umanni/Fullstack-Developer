require "test_helper"
class InertiaControllerCoverageTest < ActionDispatch::IntegrationTest
  test "index" do
    get root_path
    assert [ 200, 302 ].include?(response.status)
  end
end
