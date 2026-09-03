require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    test "admin can see dashboard stats" do
      sign_in_as users(:admin)
      get admin_root_url
      assert_response :success
      assert_select "[data-testid=total-users]", text: User.count.to_s
    end

    test "visitor is redirected to sign in" do
      get admin_root_url
      assert_redirected_to new_session_url
    end
  end
end
