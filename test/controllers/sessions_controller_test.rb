require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:member) }

  test "renders sign in" do
    get new_session_path
    assert_response :success
    assert_select "h1", "Sign in to your workspace"
  end

  test "redirects an already authenticated user away from sign in" do
    sign_in_as(@user)

    get new_session_path

    assert_redirected_to profile_path
  end

  test "redirects a standard user to profile" do
    post session_path, params: { email: @user.email, password: "SecurePass123!" }

    assert_redirected_to profile_url
    assert cookies[:session_id]
  end

  test "normalizes email casing and whitespace before authentication" do
    post session_path, params: { email: "  #{@user.email.upcase}  ", password: "SecurePass123!" }

    assert_redirected_to profile_url
    assert cookies[:session_id]
  end

  test "redirects an administrator to dashboard" do
    post session_path, params: { email: users(:admin).email, password: "SecurePass123!" }

    assert_redirected_to admin_root_url
  end

  test "returns to a same-host protected page after authentication" do
    get edit_profile_path
    assert_redirected_to new_session_path

    post session_path, params: { email: @user.email, password: "SecurePass123!" }

    assert_redirected_to edit_profile_url
  end

  test "rejects invalid credentials without disclosing which field failed" do
    post session_path, params: { email: @user.email, password: "wrong-password" }

    assert_redirected_to new_session_path
    assert_equal "The email or password is incorrect.", flash[:alert]
    assert_nil cookies[:session_id]
  end

  test "destroys the persisted session" do
    sign_in_as(@user)

    assert_difference "Session.count", -1 do
      delete session_path
    end

    assert_redirected_to root_path
    assert_empty cookies[:session_id]
  end
end
