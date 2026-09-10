require "test_helper"
class QuickMailTest < ActionMailer::TestCase
  test "reset mail" do
    user = User.create!(full_name: "Mail", email: "mail2@example.com", password: "Password123", password_confirmation: "Password123")
    mail = PasswordsMailer.reset(user)
    assert_equal [ "mail2@example.com" ], mail.to
  end
end
