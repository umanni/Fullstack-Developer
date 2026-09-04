require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup { sign_in_as users(:admin) }

    test "admin can list users" do
      get admin_users_url
      assert_response :success
      assert_match users(:member).full_name, response.body
    end

    test "admin can create user" do
      assert_difference("User.count", 1) do
        post admin_users_url, params: {
          user: {
            full_name: "Fresh User",
            email_address: "fresh@example.com",
            password: "password123",
            password_confirmation: "password123",
            role: "member"
          }
        }
      end
      assert_redirected_to admin_user_url(User.find_by(email_address: "fresh@example.com"))
    end

    test "admin can toggle role" do
      user = users(:another_member)
      assert user.member?
      patch toggle_role_admin_user_url(user)
      assert user.reload.admin?
    end

    test "admin cannot toggle own role" do
      patch toggle_role_admin_user_url(users(:admin))
      assert_redirected_to admin_users_url
      assert users(:admin).reload.admin?
    end

    test "member cannot access admin users" do
      delete session_url
      sign_in_as users(:member)
      get admin_users_url
      assert_redirected_to profile_url
    end
  end
end
