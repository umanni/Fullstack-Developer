require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:member) }

  test "renders request form" do
    get new_password_path

    assert_response :success
    assert_inertia_component "Auth/ForgotPassword"
  end

  test "sends reset instructions for a known user" do
    post passwords_path, params: { password: { email: @user.email.upcase } }

    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ]
    assert_redirected_to new_session_path
  end

  test "unknown email has the same response without sending mail" do
    post passwords_path, params: { password: { email: "missing-user@example.com" } }

    assert_enqueued_emails 0
    assert_redirected_to new_session_path
  end

  test "renders a valid reset form" do
    token = @user.password_reset_token
    get edit_password_path(token)

    assert_response :success
    assert_inertia_component "Auth/ResetPassword"
    assert_inertia_props token:
  end

  test "rejects an invalid reset token" do
    get edit_password_path("invalid token")

    assert_redirected_to new_password_path
  end

  test "updates the password and revokes all existing sessions" do
    @user.sessions.create!

    assert_changes -> { @user.reload.password_digest } do
      patch password_path(@user.password_reset_token), params: {
        user: { password: "ANewStrongPassword!123", password_confirmation: "ANewStrongPassword!123" }
      }
      assert_redirected_to new_session_path
    end

    assert_empty @user.sessions.reload
  end

  test "rejects non-matching passwords" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      patch password_path(token), params: {
        user: { password: "ANewStrongPassword!123", password_confirmation: "DoesNotMatch!123" }
      }
      assert_redirected_to edit_password_path(token)
    end
  end
end
