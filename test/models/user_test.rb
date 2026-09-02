require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "is valid with the required domain attributes" do
    assert User.new(valid_user_attributes).valid?
  end

  test "normalizes name, email, and blank remote avatar" do
    user = User.new(valid_user_attributes(full_name: "  Ada   Lovelace ", email: " ADA@EXAMPLE.COM ", avatar_image_url: "  "))

    assert_equal "Ada Lovelace", user.full_name
    assert_equal "ada@example.com", user.email
    assert_nil user.avatar_image_url
  end

  test "normalizes email values used for account lookup" do
    assert_equal "member@example.com", User.normalized_email("  MEMBER@EXAMPLE.COM  ")
  end

  test "defaults to standard user role" do
    assert_predicate User.new, :user?
  end

  test "requires an avatar source" do
    user = User.new(valid_user_attributes(avatar_image_url: nil))

    assert_not user.valid?
    assert_includes user.errors[:avatar_image], "or a remote avatar URL must be provided"
  end

  test "accepts only secure remote avatars without credentials" do
    [ "http://example.com/avatar.png", "https://user:pass@example.com/avatar.png", "not a url" ].each do |url|
      user = User.new(valid_user_attributes(avatar_image_url: url))
      assert_not user.valid?, "expected #{url.inspect} to be rejected"
    end
  end

  test "enforces case-insensitive email uniqueness" do
    user = User.new(valid_user_attributes(email: users(:member).email.upcase))

    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "requires a twelve character password" do
    user = User.new(valid_user_attributes(password: "too-short", password_confirmation: "too-short"))

    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 12 characters)"
  end

  test "accepts supported avatar uploads" do
    user = User.new(valid_user_attributes(avatar_image_url: nil))
    user.avatar_image.attach(io: File.open(Rails.root.join("public/icon.png")), filename: "avatar.png", content_type: "image/png")

    assert_predicate user, :valid?
  end

  test "rejects unsupported avatar upload types" do
    user = User.new(valid_user_attributes(avatar_image_url: nil))
    user.avatar_image.attach(io: StringIO.new("not an image"), filename: "avatar.txt", content_type: "text/plain")

    assert_not_predicate user, :valid?
    assert_includes user.errors[:avatar_image], "must be a JPEG, PNG, or WebP image"
  end

  test "rejects oversized avatar uploads" do
    user = User.new(valid_user_attributes(avatar_image_url: nil))
    user.avatar_image.attach(
      io: StringIO.new("0" * (User::MAX_AVATAR_SIZE + 1)),
      filename: "avatar.png",
      content_type: "image/png"
    )

    assert_not_predicate user, :valid?
    assert_includes user.errors[:avatar_image], "must be smaller than 5 MB"
  end

  test "builds initials from the first two names" do
    assert_equal "AL", User.new(full_name: "Ada Lovelace Byron").initials
  end
end
