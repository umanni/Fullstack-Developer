require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid member fixture" do
    assert users(:member).valid?
  end

  test "requires full name email and password" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:full_name], "can't be blank"
    assert_includes user.errors[:email_address], "can't be blank"
    assert_includes user.errors[:password], "can't be blank"
  end

  test "normalizes email and rejects invalid avatar url" do
    user = users(:member)
    user.email_address = "  UPPER@Example.COM "
    user.avatar_url = "javascript:alert(1)"
    assert_not user.valid?
    assert_equal "upper@example.com", user.email_address
    assert_includes user.errors[:avatar_url], "must be an http(s) URL"
  end

  test "role helpers" do
    assert users(:admin).admin?
    assert users(:member).member?
  end

  test "initials" do
    assert_equal "MM", users(:member).initials
  end
end
