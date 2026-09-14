require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "renders the sign in form" do
    get new_session_path

    assert_response :success
  end

  test "signs in with valid credentials" do
    post session_path, params: { session: { email: users(:member).email, password: "secret-password" } }

    assert_redirected_to profile_path
    assert_predicate cookies[:session_id], :present?
  end

  test "re-renders the form with an alert on invalid credentials" do
    post session_path, params: { session: { email: users(:member).email, password: "wrong" } }

    assert_response :unprocessable_content
    assert_empty cookies[:session_id].to_s
  end

  test "rejects a login attempt with a malformed parameter structure" do
    post session_path, params: { email: users(:member).email, password: "secret-password" }

    assert_response :bad_request
    assert_empty cookies[:session_id].to_s
  end

  test "rate limits repeated sign in attempts from the same address" do
    11.times do
      post session_path, params: { session: { email: users(:member).email, password: "wrong" } }
    end

    assert_redirected_to new_session_path
    assert_equal "Too many attempts. Try again later.", flash[:alert]
  end

  test "signs out" do
    sign_in_as users(:member)

    record = users(:member).sessions.sole

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id].to_s
    assert_nil Session.find_by(id: record.id), "the row outlived the cookie"
  end
end
