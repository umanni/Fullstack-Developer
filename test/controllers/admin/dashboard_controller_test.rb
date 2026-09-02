require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "renders live statistics for an administrator" do
    sign_in_as(users(:admin))

    get admin_root_path

    assert_response :success
    assert_select "#dashboard_stats"
    assert_select "turbo-cable-stream-source[channel='Turbo::StreamsChannel']"
    assert_match User.count.to_s, response.body
  end

  test "redirects a standard user to their profile" do
    sign_in_as(users(:member))

    get admin_root_path

    assert_redirected_to profile_path
    assert_equal "You are not authorized to access that page.", flash[:alert]
  end

  test "requires authentication" do
    get admin_root_path

    assert_redirected_to new_session_path
  end
end
