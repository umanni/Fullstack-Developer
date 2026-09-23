require "test_helper"

module Admin
  class DashboardsControllerTest < ActionDispatch::IntegrationTest
    test "admin can open dashboard" do
      sign_in_as users(:admin)
      get admin_dashboard_url
      assert_response :success
      assert_match(/Total de usuários/, response.body)
    end

    test "member is redirected away" do
      sign_in_as users(:member)
      get admin_dashboard_url
      assert_redirected_to profile_url
    end
  end
end
