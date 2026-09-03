require "test_helper"

class Users::CreateTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "creates a visitor account and broadcasts updated statistics" do
    assert_enqueued_with(job: Dashboard::BroadcastStatsJob) do
      assert_difference "User.count", 1 do
        user = Users::Create.call(attributes: valid_user_attributes)

        assert_predicate user, :persisted?
        assert_predicate user, :user?
      end
    end
  end

  test "creates an invited account with a random password and invitation email" do
    attributes = valid_user_attributes.except(:password, :password_confirmation)

    assert_enqueued_emails 1 do
      user = Users::Create.call(attributes:, invite: true, broadcast: false)

      assert_predicate user, :persisted?
      assert user.authenticate(user.password)
    end
  end

  test "does not enqueue side effects when validation fails" do
    assert_no_enqueued_jobs do
      user = Users::Create.call(attributes: valid_user_attributes(email: "invalid"), invite: true)

      assert_not_predicate user, :persisted?
    end
  end
end
