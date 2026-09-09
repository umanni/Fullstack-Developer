require "test_helper"

class MailerCoverageTest < ActionMailer::TestCase
  test "passwords mailer reset" do
    user = User.create!(full_name: "Mail", email: "mail@example.com", password: "password123", password_confirmation: "password123")
    mail = PasswordsMailer.reset(user)
    assert_equal [ "mail@example.com" ], mail.to
    assert_match "Reset", mail.subject
  end
end
