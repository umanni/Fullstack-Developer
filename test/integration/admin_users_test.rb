require "test_helper"

class AdminUsersTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(full_name: "Admin", email: "admin3@example.com", password: "Password123", password_confirmation: "Password123", role: :admin)
    @user = User.create!(full_name: "Bob", email: "bob@example.com", password: "Password123", password_confirmation: "Password123")
    sign_in_as(@admin)
  end

  test "list users" do
    get admin_users_path
    assert_response :success
    assert_match "Bob", response.body
  end

  test "create user" do
    assert_difference("User.count", 1) do
      post admin_users_path, params: { user: { full_name: "New", email: "new@example.com", password: "Password123", password_confirmation: "Password123", role: "user" } }
    end
    assert_redirected_to admin_users_path
  end

  test "update user" do
    patch admin_user_path(@user), params: { user: { full_name: "Bob Updated" } }
    assert_redirected_to admin_users_path
    assert_equal "Bob Updated", @user.reload.full_name
  end

  test "toggle role" do
    assert @user.user?
    patch toggle_role_admin_user_path(@user)
    assert_redirected_to admin_users_path
    assert @user.reload.admin?
    patch toggle_role_admin_user_path(@user)
    assert @user.reload.user?
  end

  test "delete user" do
    assert_difference("User.count", -1) do
      delete admin_user_path(@user)
    end
    assert_redirected_to admin_users_path
  end

  test "non-admin cannot access" do
    sign_in_as(@user)
    get admin_users_path
    assert_redirected_to root_path
  end
end
