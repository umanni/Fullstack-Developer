require "test_helper"
class QuickChannelAllTest < ActionDispatch::IntegrationTest
  test "all channels defined" do
    assert defined?(ApplicationCable::Connection)
    assert defined?(DashboardChannel)
    assert defined?(UserImportChannel)
  end
end
