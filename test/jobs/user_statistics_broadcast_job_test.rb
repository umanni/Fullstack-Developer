require "test_helper"

class UserStatisticsBroadcastJobTest < ActiveJob::TestCase
  test "broadcasts fresh statistics to the admin dashboard" do
    assert_broadcasts "admin_dashboard", 1 do
      UserStatisticsBroadcastJob.perform_now
    end
  end
end
