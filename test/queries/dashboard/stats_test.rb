require "test_helper"

class Dashboard::StatsTest < ActiveSupport::TestCase
  test "returns total and role counts in one result" do
    stats = Dashboard::Stats.call

    assert_equal User.count, stats.total
    assert_equal User.admin.count, stats.admins
    assert_equal User.user.count, stats.users
  end
end
