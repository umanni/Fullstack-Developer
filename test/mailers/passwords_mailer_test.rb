require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  setup { @user = users(:member) }

  test "builds a reset email with an expiring token link" do
    email = PasswordsMailer.reset(@user)

    assert_equal [ @user.email ], email.to
    assert_equal "Reset your Umanni Users password", email.subject
    assert_match %r{http://example\.com/passwords/.+/edit}, email.html_part.body.to_s
    assert_match %r{http://example\.com/passwords/.+/edit}, email.text_part.body.to_s
  end

  test "builds an invitation email with an account setup link" do
    email = PasswordsMailer.invitation(@user)

    assert_equal [ @user.email ], email.to
    assert_equal "Set up your Umanni Users account", email.subject
    assert_match "Set up your password", email.html_part.body.to_s
    assert_match %r{http://example\.com/passwords/.+/edit}, email.text_part.body.to_s
  end
end
