require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "administrator sees live dashboard data" do
    sign_in_as(users(:admin))
    get admin_root_path

    assert_response :success
    assert_inertia_component "Admin/Dashboard"
    assert_inertia_props do |props|
      props["statistics"]["total"] == User.count &&
        props["statistics"]["by_role"]["admin"] == User.admin.count &&
        props["statistics"]["by_role"]["user"] == User.user.count
    end
  end

  test "standard user is redirected to profile" do
    sign_in_as(users(:member))
    get admin_root_path

    assert_redirected_to profile_path
  end

  test "visitor is redirected to sign in" do
    get admin_root_path

    assert_redirected_to new_session_path
  end
end
