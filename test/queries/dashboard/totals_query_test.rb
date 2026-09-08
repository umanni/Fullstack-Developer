require "test_helper"

class Dashboard::TotalsQueryTest < ActiveSupport::TestCase
  test "returns total users and counts grouped by role" do
    overview = Dashboard::TotalsQuery.call(User.all)

    assert_equal User.count, overview.total_users
    assert_equal User.user.count, overview.by_role["user"]
    assert_equal User.admin.count, overview.by_role["admin"]
  end

  test "to_inertia exposes the serialization contract" do
    overview = Dashboard::TotalsQuery.call(User.all)

    assert_equal(
      { total_users: User.count, by_role: User.group(:role).count },
      overview.to_inertia
    )
    assert overview.frozen?
  end

  test "works with a pre-scoped relation" do
    scoped = User.where(role: :user)
    overview = Dashboard::TotalsQuery.call(scoped)

    assert_equal User.user.count, overview.total_users
    assert_equal(User.user.group(:role).count, overview.by_role)
  end
end
