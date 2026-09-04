require "test_helper"

class UserExtraTest < ActiveSupport::TestCase
  test "avatar_src prefers attachment then url" do
    user = users(:member)
    user.avatar_url = "https://example.com/a.png"
    assert_equal "https://example.com/a.png", user.avatar_src

    user.avatar_image.attach(
      io: StringIO.new("fake"),
      filename: "a.png",
      content_type: "image/png"
    )
    assert user.avatar_src.attached?
  end

  test "rejects oversized avatar content type via validation helper path" do
    user = users(:member)
    user.avatar_image.attach(
      io: StringIO.new("not-an-image"),
      filename: "file.pdf",
      content_type: "application/pdf"
    )
    assert_not user.valid?
    assert_includes user.errors[:avatar_image], "must be a PNG, JPEG, WEBP, or GIF image"
  end
end
