require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email" do
    user = User.new(full_name: "T", email: " DOWNCASED@EXAMPLE.COM ", password: "password123", password_confirmation: "password123")
    assert_equal("downcased@example.com", user.email)
  end

  test "valid with full_name, email, password and default role" do
    user = User.new(full_name: "Ada Lovelace", email: "ada@example.com", password: "password123", password_confirmation: "password123")
    assert user.valid?, -> { user.errors.full_messages.to_sentence }
    assert_equal "user", user.role
  end

  test "requires full_name" do
    user = User.new(full_name: "", email: "a@b.co", password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert_includes user.errors[:full_name], "can't be blank"
  end

  test "requires unique email" do
    User.create!(full_name: "First", email: "dup@example.com", password: "password123", password_confirmation: "password123")
    dup = User.new(full_name: "Second", email: "DUP@example.com", password: "password123", password_confirmation: "password123")
    assert_not dup.valid?
  end

  test "admin role allowed" do
    user = User.new(full_name: "Root", email: "root@example.com", role: :admin, password: "password123", password_confirmation: "password123")
    assert user.valid?
    assert user.admin?
  end
end
