require "test_helper"

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "shows the total and the count for each role" do
    get admin_dashboard_path

    assert_response :success
    assert_select "#metric-total", text: User.count.to_s
    assert_select "#metric-admin", text: User.admin.count.to_s
    assert_select "#metric-user", text: User.user.count.to_s
  end

  test "subscribes to the dashboard stream" do
    get admin_dashboard_path

    assert_select "turbo-cable-stream-source"
  end

  test "shows a role with no members as zero rather than dropping the tile" do
    User.user.destroy_all

    get admin_dashboard_path

    assert_select "#metric-user", text: "0"
    assert_select "#metric-admin", text: User.admin.count.to_s
  end

  test "is closed to users who are not admins" do
    sign_out
    sign_in_as users(:member)

    get admin_dashboard_path

    assert_redirected_to profile_url
  end
end
