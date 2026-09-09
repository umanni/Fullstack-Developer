require "test_helper"
class QuickMailerAllTest < ActionMailer::TestCase
  test "mailers defined" do
    assert defined?(PasswordsMailer)
    assert defined?(ApplicationMailer)
  end
end
