require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "admin is redirected to dashboard after login" do
    post session_url, params: { email_address: users(:admin).email_address, password: "password123" }
    assert_redirected_to admin_root_url
  end

  test "member is redirected to profile after login" do
    post session_url, params: { email_address: users(:member).email_address, password: "password123" }
    assert_redirected_to profile_url
  end

  test "rejects invalid credentials" do
    post session_url, params: { email_address: users(:member).email_address, password: "wrong" }
    assert_redirected_to new_session_url
    assert_equal "Try another email address or password.", flash[:alert]
  end
end
