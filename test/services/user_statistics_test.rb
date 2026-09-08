require "test_helper"

class UserStatisticsTest < ActiveSupport::TestCase
  test "returns total users and a complete role breakdown" do
    statistics = UserStatistics.call

    assert_equal User.count, statistics[:total]
    assert_equal User.admin.count, statistics[:by_role][:admin]
    assert_equal User.user.count, statistics[:by_role][:user]
    assert_instance_of String, statistics[:generated_at]
  end
end
