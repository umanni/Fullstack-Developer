require "test_helper"

module Admin
  class UsersControllerExtraTest < ActionDispatch::IntegrationTest
    setup { sign_in_as users(:admin) }

    test "admin can show and update user" do
      user = users(:another_member)
      get admin_user_url(user)
      assert_response :success

      patch admin_user_url(user), params: { user: { full_name: "Casey Updated" } }
      assert_redirected_to admin_user_url(user)
      assert_equal "Casey Updated", user.reload.full_name
    end

    test "admin can delete other users but not self" do
      delete admin_user_url(users(:admin))
      assert_redirected_to admin_users_url
      assert User.exists?(users(:admin).id)

      assert_difference("User.count", -1) do
        delete admin_user_url(users(:another_member))
      end
    end

    test "invalid create re-renders form" do
      post admin_users_url, params: { user: { full_name: "", email_address: "", password: "x", role: "member" } }
      assert_response :unprocessable_entity
    end
  end
end
