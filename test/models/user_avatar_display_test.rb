require "test_helper"

class UserAvatarDisplayTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(full_name: "Avatar User", email: "avatar-display@example.com", password: "password123", password_confirmation: "password123")
  end

  test "prefers attached image over url" do
    @user.avatar_image.attach(io: StringIO.new("img"), filename: "a.png", content_type: "image/png")
    @user.update!(avatar_url: "https://example.com/a.png")

    assert_equal @user.avatar_image, @user.avatar_display
  end

  test "falls back to url without attachment" do
    @user.update!(avatar_url: "https://example.com/b.png")

    assert_equal "https://example.com/b.png", @user.avatar_display
  end

  test "returns nil without image or url" do
    assert_nil @user.avatar_display
  end
end
