require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "renders the public landing page with security headers" do
    get root_path

    assert_response :success
    assert_select "h1", /User management/
    assert_match "frame-ancestors 'none'", response.headers.fetch("Content-Security-Policy")
    assert_match(/script-src 'self' 'nonce-[^']+'/i, response.headers.fetch("Content-Security-Policy"))
    assert_equal "nosniff", response.headers["X-Content-Type-Options"]
  end

  test "redirects a signed-in standard user to the profile" do
    sign_in_as(users(:member))

    get root_path

    assert_redirected_to profile_path
  end

  test "redirects a signed-in administrator to the dashboard" do
    sign_in_as(users(:admin))

    get root_path

    assert_redirected_to admin_root_path
  end

  test "serves installable application metadata and the service worker endpoint" do
    get pwa_manifest_path(format: :json)
    assert_response :success
    assert_equal "Umanni Users", response.parsed_body.fetch("name")

    get pwa_service_worker_path
    assert_response :success
  end
end
