require "test_helper"

class Users::RoleChangerTest < ActiveSupport::TestCase
  test "promotes a standard user" do
    Users::RoleChanger.call(user: users(:member), actor: users(:admin))

    assert_predicate users(:member).reload, :admin?
  end

  test "demotes an administrator when another admin remains" do
    Users::RoleChanger.call(user: users(:another_admin), actor: users(:admin))

    assert_predicate users(:another_admin).reload, :user?
  end

  test "does not allow administrators to change their own role" do
    error = assert_raises(Users::RoleChanger::Error) do
      Users::RoleChanger.call(user: users(:admin), actor: users(:admin))
    end

    assert_match(/own role/, error.message)
  end

  test "does not demote the last administrator" do
    users(:another_admin).update!(role: :user)

    error = assert_raises(Users::RoleChanger::Error) do
      Users::RoleChanger.call(user: users(:admin), actor: users(:another_admin))
    end

    assert_match(/last administrator/, error.message)
    assert_predicate users(:admin).reload, :admin?
  end
end
