require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  test "reset email contains recipient and expiring token link" do
    email = PasswordsMailer.reset(users(:member))

    assert_equal [ users(:member).email ], email.to
    assert_equal "Set or reset your password", email.subject
    assert_match %r{/passwords/.+/edit}, email.text_part.body.to_s
  end
end
