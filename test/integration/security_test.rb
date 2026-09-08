require "test_helper"

class SecurityTest < ActionDispatch::IntegrationTest
  test "state-changing requests enforce CSRF tokens" do
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true

    post session_path, params: {
      session: { email: users(:member).email, password: "StrongPassword!123" }
    }

    assert_response :unprocessable_content
  ensure
    ActionController::Base.allow_forgery_protection = previous
  end

  test "SQL injection-like credentials never authenticate" do
    post session_path, params: {
      session: { email: "' OR 1=1--", password: "StrongPassword!123" }
    }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "an unauthenticated direct object request does not expose a profile" do
    get edit_admin_user_path(users(:admin))

    assert_redirected_to new_session_path
  end
end
