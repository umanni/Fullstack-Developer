require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes the email address on save" do
    user = users(:two)

    user.update!(email_address: "  Mixed@IAM.TEST ")

    assert_equal "mixed@iam.test", user.reload.email_address
  end

  test "avatar_source prefers an attached avatar over the URL" do
    user = users(:two)
    user.avatar.attach(io: StringIO.new("image"), filename: "avatar.png", content_type: "image/png")

    assert user.avatar_source.attached?
    assert_equal "avatar.png", user.avatar_source.filename.to_s
  end

  test "avatar_source falls back to the URL when nothing is attached" do
    assert_equal users(:two).avatar_url, users(:two).avatar_source
  end

  test "password reset token is invalidated when the password changes" do
    user = users(:two)
    token = user.generate_token_for(:password_reset)

    assert_equal user, User.find_by_token_for!(:password_reset, token)

    user.update!(password: "Changed123!", password_confirmation: "Changed123!")

    assert_raises(ActiveSupport::MessageVerifier::InvalidSignature) do
      User.find_by_token_for!(:password_reset, token)
    end
  end
end
