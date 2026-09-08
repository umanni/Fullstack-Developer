require "test_helper"

class PasswordsFlowTest < ActionDispatch::IntegrationTest
  test "forgot password page is reachable without a session" do
    get new_password_path

    assert_inertia_response
    assert_inertia_component "Auth/ForgotPassword"
    assert_inertia_props({ urls: { login_url: new_session_path } })
  end

  test "requesting a reset for a known email enqueues the reset mailer" do
    user = users(:two)

    assert_emails 1 do
      post passwords_path, params: { email_address: user.email_address }
    end

    assert_redirected_to new_session_path
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "requesting a reset for an unknown email does not leak and still redirects" do
    assert_no_emails do
      post passwords_path, params: { email_address: "ghost@iam.test" }
    end

    assert_redirected_to new_session_path
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "resetting the password succeeds with a valid token" do
    user = users(:two)
    token = user.generate_token_for(:password_reset)

    get edit_password_path(token)
    assert_inertia_response
    assert_inertia_component "Auth/ResetPassword"
    assert_inertia_props({ token: token })

    patch password_path(token), params: {
      password: "NewPassword123!",
      password_confirmation: "NewPassword123!"
    }

    assert_redirected_to new_session_path
    assert_equal "Password has been reset.", flash[:notice]

    post session_path, params: { email_address: user.email_address, password: "NewPassword123!" }
    assert_redirected_to profile_path
  end

  test "an invalid token is rejected with an alert" do
    token = users(:two).generate_token_for(:password_reset)
    forged = token.chop + (token.end_with?("a") ? "b" : "a")

    get edit_password_path(forged)

    assert_redirected_to new_password_path
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end

  test "re-renders the reset form when password rules are violated" do
    user = users(:two)
    token = user.generate_token_for(:password_reset)

    patch password_path(token), params: {
      password: "short",
      password_confirmation: "short"
    }

    assert_inertia_response
    assert_inertia_component "Auth/ResetPassword"
    assert_inertia_props { |props| props.dig(:errors, :password).present? }
  end
end
