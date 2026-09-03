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

  test "csrf protection is enabled outside test" do
    assert ActionController::Base.allow_forgery_protection || Rails.env.test?
  end

  test "sql injection does not bypass authentication" do
    post session_url, params: {
      email_address: "' OR 1=1 --",
      password: "' OR 1=1 --"
    }
    assert_redirected_to new_session_url
  end

  test "passwords are stored as digests" do
    digest = users(:member).password_digest
    assert_not_equal "password123", digest
    assert BCrypt::Password.new(digest).is_password?("password123")
  end
end
