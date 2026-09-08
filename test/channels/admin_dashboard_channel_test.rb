require "test_helper"

class AdminDashboardChannelTest < ActionCable::Channel::TestCase
  test "administrator subscribes to dashboard updates" do
    stub_connection current_user: users(:admin)

    subscribe

    assert_predicate subscription, :confirmed?
    assert_has_stream "admin_dashboard"
  end

  test "standard user is rejected" do
    stub_connection current_user: users(:member)

    subscribe

    assert_predicate subscription, :rejected?
  end
end
