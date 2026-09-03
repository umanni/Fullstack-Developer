require "test_helper"

module Users
  class DashboardStatsTest < ActiveSupport::TestCase
    test "counts users by role" do
      stats = Users::DashboardStats.call
      assert_equal User.count, stats.total
      assert_equal User.admin.count, stats.admins
      assert_equal User.member.count, stats.members
    end
  end
end
