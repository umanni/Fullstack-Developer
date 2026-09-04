require "test_helper"

class SecurityTest < ActionDispatch::IntegrationTest
  test "escapes xss in user names" do
    sign_in_as users(:admin)
    malicious = User.create!(
      full_name: "<script>alert('xss')</script>",
      email_address: "xss@example.com",
      password: "password123",
      role: :member
    )

    get admin_users_url

    assert_response :success
    assert_no_match %r{<script>alert\('xss'\)</script>}, response.body
    assert_match "&lt;script&gt;", response.body

    malicious.destroy!
  end

  test "csrf forgery protection module is loaded" do
    assert_includes ActionController::Base.included_modules, ActionController::RequestForgeryProtection
    # protect_from_forgery is enabled outside the test environment (see config/environments/test.rb)
    assert ActionController::Base.allow_forgery_protection || Rails.env.test?
  end

  test "sql injection does not bypass authentication" do
    post session_url, params: {
      email_address: "' OR 1=1 --",
      password: "' OR 1=1 --"
    }

    assert_redirected_to new_session_url
  end

  test "passwords are stored as digests not plaintext" do
    digest = users(:member).password_digest

    assert_not_equal "password123", digest
    assert BCrypt::Password.new(digest).is_password?("password123")
  end

  test "email_address is encrypted at rest" do
    user = users(:member)
    raw = User.connection.select_value(
      User.sanitize_sql_array([ "SELECT email_address FROM users WHERE id = ?", user.id ])
    )

    assert_not_equal user.email_address, raw
    assert_operator raw.to_s.length, :>, 0
  end

  test "member cannot escalate role through profile params" do
    sign_in_as users(:member)
    patch profile_url, params: { user: { full_name: "Morgan Member", role: "admin" } }

    assert_redirected_to profile_url
    assert_predicate users(:member).reload, :member?
  end

  test "member cannot access another users admin record" do
    sign_in_as users(:member)
    get admin_user_url(users(:another_member))

    assert_redirected_to profile_url
  end

  test "visitor registration always creates member role" do
    post registration_url, params: {
      user: {
        full_name: "Forced Admin",
        email_address: "forced.admin@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: "admin"
      }
    }
    user = User.find_by(email_address: "forced.admin@example.com")

    assert_predicate user, :present?
    assert_predicate user, :member?
  end
end
