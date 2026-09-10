require "test_helper"

class AvatarUrlTest < ActiveSupport::TestCase
  test "accepts remote avatar_url" do
    user = User.new(full_name: "Pic", email: "pic@example.com", password: "Password123", password_confirmation: "Password123", avatar_url: "https://example.com/a.png")
    assert user.valid?, -> { user.errors.full_messages.to_sentence }
  end

  test "rejects invalid avatar_url" do
    user = User.new(full_name: "Pic", email: "pic2@example.com", password: "Password123", password_confirmation: "Password123", avatar_url: "not-a-url")
    assert_not user.valid?
  end
end
