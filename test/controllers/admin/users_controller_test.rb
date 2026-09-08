require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in_as(@admin)
  end

  test "lists paginated users with filters" do
    get admin_users_path, params: { query: "Linus", role: "user" }

    assert_response :success
    assert_inertia_component "Admin/Users/Index"
    assert_inertia_props filters: { query: "Linus", role: "user" }
    assert_equal [ users(:member).id ], inertia.props[:users].map { |user| user[:id] }
  end

  test "invalid role filter is ignored" do
    get admin_users_path, params: { role: "owner' OR 1=1--" }

    assert_response :success
    assert_equal User.count, inertia.props.dig(:pagination, :count)
  end

  test "renders new user page" do
    get new_admin_user_path

    assert_response :success
    assert_inertia_component "Admin/Users/New"
  end

  test "creates a user with an explicit role" do
    assert_difference "User.count", 1 do
      post admin_users_path, params: {
        user: {
          full_name: "New Administrator",
          email: "new-admin@example.com",
          role: "admin",
          password: "StrongPassword!123",
          password_confirmation: "StrongPassword!123",
          remove_avatar: "0"
        }
      }
    end

    assert_redirected_to admin_users_path
    assert_predicate User.find_by!(email: "new-admin@example.com"), :admin?
  end

  test "invalid create redirects with no persisted record" do
    assert_no_difference "User.count" do
      post admin_users_path, params: {
        user: { full_name: "", email: "bad", role: "user", password: "short" }
      }
    end

    assert_redirected_to new_admin_user_path
  end

  test "renders an edit page" do
    get edit_admin_user_path(users(:member))

    assert_response :success
    assert_inertia_component "Admin/Users/Edit"
    assert_inertia_props { |props| props["user"]["id"] == users(:member).id }
  end

  test "updates details but ignores role mass assignment" do
    member = users(:member)
    patch admin_user_path(member), params: {
      user: { full_name: "Changed Name", email: member.email, role: "admin", password: "", password_confirmation: "" }
    }

    assert_redirected_to admin_users_path
    assert_equal "Changed Name", member.reload.full_name
    assert_predicate member, :user?
  end

  test "toggles another user's role through the guarded service" do
    patch toggle_role_admin_user_path(users(:member))

    assert_redirected_to admin_users_path
    assert_predicate users(:member).reload, :admin?
  end

  test "cannot toggle own role" do
    patch toggle_role_admin_user_path(@admin)

    assert_redirected_to admin_users_path
    assert_predicate @admin.reload, :admin?
  end

  test "deletes another user" do
    assert_difference "User.count", -1 do
      delete admin_user_path(users(:member))
    end

    assert_redirected_to admin_users_path
  end

  test "cannot delete own user from admin list" do
    assert_no_difference "User.count" do
      delete admin_user_path(@admin)
    end

    assert_redirected_to admin_users_path
  end

  test "standard users cannot access any admin user record" do
    sign_out
    sign_in_as(users(:member))

    get edit_admin_user_path(@admin)

    assert_redirected_to profile_path
  end
end
