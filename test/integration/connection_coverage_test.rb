require "test_helper"
class ConnectionCoverageTest < ActionDispatch::IntegrationTest
  test "connection exists" do
    assert defined?(ApplicationCable::Connection)
  end
end
