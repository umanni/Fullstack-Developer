require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as users(:admin)
    end

    test "admin can list users excluding self" do
      get admin_users_url
      assert_response :success
      assert_match users(:member).email, response.body
      assert_no_match %r{/admin/users/#{users(:admin).id}}, response.body
    end

    test "admin can create user" do
      assert_difference("User.count", 1) do
        post admin_users_url, params: {
          user: {
            full_name: "Created User",
            email: "created@example.com",
            password: "password123",
            password_confirmation: "password123",
            user_role_id: user_roles(:member).id
          }
        }
      end
      assert_redirected_to admin_user_url(User.find_by!(email: "created@example.com"))
    end

    test "admin can toggle role" do
      user = users(:member)
      assert_not user.admin?
      patch toggle_role_admin_user_url(user)
      assert user.reload.admin?
    end

    test "non-admin cannot access admin users" do
      delete session_url
      sign_in_as users(:member)
      get admin_users_url
      assert_redirected_to profile_url
    end
  end
end
