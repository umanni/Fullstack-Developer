require "test_helper"

class DashboardChannelTest < ActionCable::Channel::TestCase
  tests DashboardChannel::Channel
  test "subscribes an admin reader to the dashboard_stats stream" do
    stub_connection current_user: users(:one)

    subscribe

    assert subscription.confirmed?
    assert_has_stream "dashboard_stats"
  end

  test "rejects non-admin subscriptions" do
    stub_connection current_user: users(:two)

    subscribe

    assert subscription.rejected?
  end
end
