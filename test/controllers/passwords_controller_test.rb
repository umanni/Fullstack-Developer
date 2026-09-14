require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "shows the form" do
    get new_password_path

    assert_response :success
  end

  test "enqueues the reset mail and says so without confirming the address" do
    post passwords_path, params: { password_reset: { email: @user.email } }

    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ]
    assert_redirected_to new_session_path

    follow_redirect!

    assert_notice "reset instructions are on the way"
  end

  test "create for an unknown user redirects but sends no mail" do
    post passwords_path, params: { password_reset: { email: "missing-user@example.com" } }

    assert_enqueued_emails 0
    assert_redirected_to new_session_path

    follow_redirect!

    assert_notice "reset instructions are on the way"
  end

  test "opens the form for a valid token" do
    get edit_password_path(@user.password_reset_token)

    assert_response :success
  end

  test "refuses a token this application did not sign" do
    get edit_password_path("invalid token")

    assert_redirected_to new_password_path

    follow_redirect!

    assert_notice "reset link is invalid"
  end

  test "resetting the password signs every browser out" do
    @user.sessions.create!
    @user.sessions.create!

    assert_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password_reset: { password: "a-new-password", password_confirmation: "a-new-password" } }

      assert_redirected_to new_session_path
    end

    assert_empty @user.sessions.reload

    follow_redirect!

    assert_notice "Password has been reset"
  end

  # has_secure_password ignores a blank assignment, so nothing but this stops a reset
  # that saves cleanly, destroys every session and leaves the old password working.
  test "refuses an empty password instead of reporting a reset that did not happen" do
    @user.sessions.create!
    digest = @user.password_digest

    put password_path(@user.password_reset_token), params: { password_reset: { password: "", password_confirmation: "" } }

    assert_response :unprocessable_content
    assert_select "p.field-error", text: "Password can't be blank"
    assert_equal digest, @user.reload.password_digest
    assert_not_empty @user.sessions.reload, "the sessions were destroyed for a reset that did not happen"
  end

  # assert_enqueued_email_with never renders the body, so a broken link in the template
  # ships green. This opens what the person receives.
  test "sends a link that opens the form for this account" do
    mail = PasswordsMailer.reset(@user)

    link = mail.html_part ? mail.html_part.body.to_s : mail.body.to_s
    token = link[%r{/passwords/([^/"]+)/edit}, 1]

    assert token, "the mail carries no reset link"

    get edit_password_path(token)

    assert_response :success
  end

  test "refuses a confirmation that does not match" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: { password_reset: { password: "no-match-here", password_confirmation: "different-one" } }
    end

    assert_response :unprocessable_content
    assert_select "p.field-error", text: "Password confirmation doesn't match Password"
  end

  test "update reports the real reason when the new password is too short" do
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password_reset: { password: "short", password_confirmation: "short" } }
    end

    assert_response :unprocessable_content
    assert_select "p.field-error", text: /Password is too short/
  end

  private
    def assert_notice(text)
      assert_select "div", /#{text}/
    end
end
