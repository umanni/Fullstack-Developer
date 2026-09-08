require "test_helper"

class UserPresenterTest < ActiveSupport::TestCase
  test "serializes public user attributes without credentials" do
    payload = UserPresenter.new(users(:member)).as_json

    assert_equal users(:member).id, payload[:id]
    assert_equal "Linus Member", payload[:full_name]
    assert_nil payload[:avatar_url]
    assert_not payload.key?(:password_digest)
  end

  test "includes the Active Storage path for an avatar" do
    user = users(:member)
    user.avatar_image.attach(io: StringIO.new("image"), filename: "avatar.png", content_type: "image/png")

    assert_match %r{^/rails/active_storage/}, UserPresenter.new(user).as_json[:avatar_url]
  end
end
