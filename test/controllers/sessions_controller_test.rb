require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "admin is redirected to dashboard after login" do
    post session_url, params: { email: users(:admin).email, password: "password123" }
    assert_redirected_to admin_dashboard_url
  end

  test "member is redirected to profile after login" do
    post session_url, params: { email: users(:member).email, password: "password123" }
    assert_redirected_to profile_url
  end

  test "invalid credentials are rejected" do
    post session_url, params: { email: users(:admin).email, password: "wrong" }
    assert_redirected_to new_session_path
    follow_redirect!
    assert_match(/E-mail ou senha inválidos/, response.body)
  end
end
