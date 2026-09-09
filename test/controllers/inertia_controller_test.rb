require "test_helper"

class ControllerCoverageTest < ActionDispatch::IntegrationTest
  test "inertia controller responds" do
    get root_path
    assert [ 200, 302 ].include?(response.status)
  end
end
