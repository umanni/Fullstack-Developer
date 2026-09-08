require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:member) }

  test "renders the Inertia sign-in page" do
    get new_session_path

    assert_response :success
    assert_inertia_component "Auth/Login"
  end

  test "standard user signs in and is redirected to their profile" do
    post session_path, params: { session: { email: @user.email.upcase, password: "StrongPassword!123" } }

    assert_redirected_to profile_url
    assert cookies[:session_id]

    follow_redirect!
    assert_response :success
    assert_inertia_component "Profile/Show"
  end

  test "session cookie is secure only for HTTPS requests" do
    post session_path, params: { session: { email: @user.email, password: "StrongPassword!123" } }

    assert_no_match(/;\s*secure(?:;|$)/i, response.headers["Set-Cookie"].to_s)

    https!
    post session_path, params: { session: { email: @user.email, password: "StrongPassword!123" } }

    assert_match(/;\s*secure(?:;|$)/i, response.headers["Set-Cookie"].to_s)
  end

  test "administrator signs in and is redirected to the dashboard" do
    post session_path, params: { session: { email: users(:admin).email, password: "StrongPassword!123" } }

    assert_redirected_to admin_root_url
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { session: { email: @user.email, password: "incorrect-password" } }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "an authenticated visitor does not see the sign-in page" do
    sign_in_as(@user)

    get new_session_path

    assert_redirected_to profile_url
  end

  test "destroy expires the session" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
    assert_not Session.exists?(Current.session&.id)
  end
end
