require "test_helper"

class Users::PolicyTest < ActiveSupport::TestCase
  setup do
    @policy = Users::Policy.new(users(:one))
  end

  test "an admin cannot delete themselves" do
    refute @policy.destructible?(users(:one), users(:one))
  end

  test "an admin cannot demote themselves" do
    refute @policy.demotable?(users(:one), users(:one))
  end

  test "a target which is the last admin cannot be deleted or demoted" do
    refute @policy.destructible?(users(:two), users(:one))
    refute @policy.demotable?(users(:two), users(:one))
  end

  test "an admin can delete and demote a regular user" do
    assert @policy.destructible?(users(:one), users(:two))
    assert @policy.demotable?(users(:one), users(:two))
  end

  test "an admin who is not the last one can be deleted and demoted" do
    second_admin = User.create!(
      full_name: "Bruce Backup",
      email_address: "bruce@iam.test",
      password: "Password123!",
      role: :admin,
      avatar_url: "https://example.com/avatars/bruce.png"
    )
    policy = Users::Policy.new(second_admin)

    assert policy.destructible?(second_admin, users(:one))
    assert policy.demotable?(second_admin, users(:one))
  end
end
