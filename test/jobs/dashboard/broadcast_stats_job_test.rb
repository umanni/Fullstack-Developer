require "test_helper"

class Dashboard::BroadcastStatsJobTest < ActiveJob::TestCase
  test "broadcasts the current dashboard statistics" do
    assert_nothing_raised do
      Dashboard::BroadcastStatsJob.perform_now
    end
  end
end
