require "test_helper"

class Users::ToggleRoleTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "promotes a standard user" do
    user = users(:member)

    assert_enqueued_with(job: Dashboard::BroadcastStatsJob) do
      Users::ToggleRole.call(user:)
    end

    assert_predicate user.reload, :admin?
  end

  test "demotes an administrator while another remains" do
    admin = users(:admin)

    Users::ToggleRole.call(user: admin)

    assert_predicate admin.reload, :user?
  end

  test "does not demote the final administrator" do
    users(:second_admin).update!(role: :user)
    admin = users(:admin)

    assert_no_enqueued_jobs { Users::ToggleRole.call(user: admin) }

    assert_predicate admin.reload, :admin?
    assert_includes admin.errors[:base], Users::ToggleRole::LAST_ADMIN_MESSAGE
  end
end
