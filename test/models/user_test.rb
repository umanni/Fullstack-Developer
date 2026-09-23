require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(
      full_name: "Ada Lovelace",
      email: "ada@example.com",
      password: "password123",
      user_role: user_roles(:member)
    )
    assert user.valid?
  end

  test "requires email and full name" do
    user = User.new(password: "password123", user_role: user_roles(:member))
    assert_not user.valid?
    assert_includes user.errors[:email], "não pode ficar em branco"
    assert_includes user.errors[:full_name], "não pode ficar em branco"
  end

  test "normalizes email" do
    user = users(:member)
    user.update!(email: "  RegULAR@Example.COM ")
    assert_equal "regular@example.com", user.reload.email
  end

  test "admin? reflects role" do
    assert users(:admin).admin?
    assert_not users(:member).admin?
  end

  test "toggle_role! switches admin flag" do
    user = users(:member)
    user.toggle_role!
    assert user.reload.admin?
    user.toggle_role!
    assert_not user.reload.admin?
  end

  test "rejects invalid avatar_url" do
    user = users(:member)
    user.avatar_url = "not-a-url"
    assert_not user.valid?
    assert_includes user.errors[:avatar_url], "deve ser uma URL HTTP(S) válida"
  end

  test "dashboard_stats counts roles" do
    stats = User.dashboard_stats
    assert_equal User.count, stats[:total]
    assert_equal User.admins.count, stats[:admins]
    assert_equal User.non_admins.count, stats[:non_admins]
  end
end
