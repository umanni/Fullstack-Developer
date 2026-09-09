require "test_helper"
class QuickChannelTest < ActionDispatch::IntegrationTest
  test "channel exists" do
    assert defined?(DashboardChannel)
    assert defined?(UserImportChannel)
  end
end
