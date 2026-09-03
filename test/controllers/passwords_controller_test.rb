require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "renders forgot password form" do
    get new_password_url
    assert_response :success
  end

  test "queues reset for known email" do
    assert_enqueued_emails 1 do
      post passwords_url, params: { email_address: users(:member).email_address }
    end
    assert_redirected_to new_session_url
  end

  test "does not reveal unknown emails" do
    assert_no_enqueued_emails do
      post passwords_url, params: { email_address: "missing@example.com" }
    end
    assert_redirected_to new_session_url
  end

  test "rejects invalid reset token" do
    get edit_password_url(token: "invalid")
    assert_redirected_to new_password_url
  end
end
