require "test_helper"

class Users::DestroyTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "deletes a standard user and broadcasts updated statistics" do
    user = users(:member)

    assert_enqueued_with(job: Dashboard::BroadcastStatsJob) do
      assert_difference "User.count", -1 do
        Users::Destroy.call(user:)
      end
    end

    assert_predicate user, :destroyed?
  end

  test "does not delete the final administrator" do
    users(:second_admin).update!(role: :user)
    admin = users(:admin)

    assert_no_difference "User.count" do
      Users::Destroy.call(user: admin)
    end

    assert_includes admin.errors[:base], Users::Destroy::LAST_ADMIN_MESSAGE
  end

  test "allows an administrator deletion while another administrator remains" do
    admin = users(:admin)

    assert_difference "User.count", -1 do
      Users::Destroy.call(user: admin)
    end
  end
end
