require "test_helper"

class SessionsFlowTest < ActionDispatch::IntegrationTest
  test "invalid credentials keep the visitor on the login page with an alert" do
    post session_path, params: { email_address: users(:two).email_address, password: "wrong-password" }

    assert_redirected_to new_session_path
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "signing out invalidates the session" do
    log_in_as users(:two)
    session = users(:two).sessions.order(:created_at).last
    assert session

    delete session_path

    assert_redirected_to new_session_path
    assert_nil Session.find_by(id: session.id)
  end

  test "unauthenticated users are redirected to login and returned after signing in" do
    get profile_path
    assert_redirected_to new_session_path

    follow_redirect!
    assert_inertia_component "Auth/Login"

    post session_path, params: { email_address: users(:two).email_address, password: "Password123!" }
    assert_redirected_to profile_path
  end

  test "unauthenticated root redirects through login" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "create is rate limited after ten attempts" do
    user = users(:two)

    10.times do
      post session_path, params: { email_address: user.email_address, password: "wrong" }
      assert_not flash[:alert] == "Try again later."
    end

    post session_path, params: { email_address: user.email_address, password: "wrong" }
    assert_redirected_to new_session_path
    assert_equal "Try again later.", flash[:alert]
  end

  test "return_to is consumed once after authentication" do
    get profile_path
    post session_path, params: { email_address: users(:two).email_address, password: "Password123!" }
    assert_redirected_to profile_path

    post session_path, params: { email_address: users(:two).email_address, password: "Password123!" }
    assert_redirected_to profile_path
  end
end
