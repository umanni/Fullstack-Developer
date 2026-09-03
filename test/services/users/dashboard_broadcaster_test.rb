require "test_helper"

module Users
  class DashboardBroadcasterTest < ActiveSupport::TestCase
    test "broadcasts without raising" do
      assert_nothing_raised { Users::DashboardBroadcaster.call }
    end
  end
end
