require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:member) }

  test "renders password recovery" do
    get new_password_path
    assert_response :success
  end

  test "queues reset email for a known user" do
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ] do
      post passwords_path, params: { email: @user.email }
    end
    assert_redirected_to new_session_path
  end

  test "returns identical response for an unknown email" do
    assert_no_enqueued_emails do
      post passwords_path, params: { email: "missing@example.com" }
    end
    assert_redirected_to new_session_path
    assert_match "if user with that email", flash[:notice]
  end

  test "renders a valid reset token" do
    get edit_password_path(@user.password_reset_token)
    assert_response :success
  end

  test "rejects an invalid reset token" do
    get edit_password_path("invalid-token")
    assert_redirected_to new_password_path
    assert_match "invalid or has expired", flash[:alert]
  end

  test "updates password and revokes every session" do
    @user.sessions.create!

    assert_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: {
        user: { password: "NewSecurePass123!", password_confirmation: "NewSecurePass123!" }
      }
    end

    assert_redirected_to new_session_path
    assert_empty @user.sessions.reload
  end

  test "rejects non-matching passwords" do
    token = @user.password_reset_token

    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: {
        user: { password: "NewSecurePass123!", password_confirmation: "DifferentPass123!" }
      }
    end

    assert_redirected_to edit_password_path(token)
  end
end
