require "test_helper"

class ChannelCoverageTest < ActionDispatch::IntegrationTest
  test "dashboard channel exists" do
    assert defined?(DashboardChannel)
  end

  test "user import channel exists" do
    assert defined?(UserImportChannel)
  end
end
