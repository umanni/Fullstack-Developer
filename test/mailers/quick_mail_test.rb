require "test_helper"
class QuickMailTest < ActionMailer::TestCase
  test "reset mail" do
    user = User.create!(full_name: "Mail", email: "mail2@example.com", password: "password123", password_confirmation: "password123")
    mail = PasswordsMailer.reset(user)
    assert_equal [ "mail2@example.com" ], mail.to
  end
end
