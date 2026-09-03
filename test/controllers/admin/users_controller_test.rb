require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup { sign_in_as(users(:admin)) }

  test "renders new and edit forms" do
    get new_admin_user_path
    assert_response :success
    assert_select "form[action='#{admin_users_path}']"

    get edit_admin_user_path(users(:member))
    assert_response :success
    assert_select "form[action='#{admin_user_path(users(:member))}']"
  end

  test "lists users and escapes names in rendered HTML" do
    user = User.create!(valid_user_attributes(full_name: "<script>alert(1)</script>"))

    get admin_users_path

    assert_response :success
    assert_no_match "<script>alert(1)</script>", response.body
    assert_includes response.body, ERB::Util.html_escape(user.full_name)
  end

  test "searches without interpreting SQL injection syntax" do
    get admin_users_path, params: { query: "' OR 1=1 --" }

    assert_response :success
    assert_select "[data-testid=user-row]", count: 0
  end

  test "creates an invited user" do
    assert_enqueued_emails 1 do
      assert_difference "User.count", 1 do
        post admin_users_path, params: {
          user: valid_user_attributes(email: "managed@example.com").except(:password, :password_confirmation)
        }
      end
    end

    assert_redirected_to admin_users_path
  end

  test "renders validation errors when creation fails" do
    assert_no_difference "User.count" do
      post admin_users_path, params: { user: { full_name: "", email: "invalid", avatar_image_url: "" } }
    end

    assert_response :unprocessable_entity
    assert_select "[role=alert]"
  end

  test "updates a user without allowing role assignment" do
    user = users(:member)

    patch admin_user_path(user), params: {
      user: { full_name: "Managed Member", email: user.email, avatar_image_url: user.avatar_image_url, role: :admin }
    }

    assert_redirected_to admin_users_path
    assert_equal "Managed Member", user.reload.full_name
    assert_predicate user, :user?
  end

  test "renders validation errors when an update fails" do
    user = users(:member)

    patch admin_user_path(user), params: { user: { full_name: "", email: "invalid", avatar_image_url: "" } }

    assert_response :unprocessable_entity
    assert_select "[role=alert]"
    assert_equal users(:member).email, user.reload.email
  end

  test "toggles a role through the explicit endpoint" do
    user = users(:member)

    patch toggle_role_admin_user_path(user)

    assert_redirected_to admin_users_path
    assert_predicate user.reload, :admin?
  end

  test "deletes a managed user" do
    user = users(:member)

    assert_difference "User.count", -1 do
      delete admin_user_path(user)
    end

    assert_redirected_to admin_users_path
  end

  test "deleting the signed-in administrator terminates their session" do
    admin = users(:admin)

    assert_difference [ "User.count", "Session.count" ], -1 do
      delete admin_user_path(admin)
    end

    assert_redirected_to root_path
    assert_empty cookies[:session_id]
  end

  test "does not demote the final administrator" do
    users(:second_admin).update!(role: :user)
    admin = users(:admin)

    patch toggle_role_admin_user_path(admin)

    assert_redirected_to admin_users_path
    assert_match "last administrator", flash[:alert]
    assert_predicate admin.reload, :admin?
  end

  test "a self-demoted administrator is redirected to their profile" do
    admin = users(:admin)

    patch toggle_role_admin_user_path(admin)

    assert_redirected_to profile_path
    assert_predicate admin.reload, :user?
  end

  test "does not expose administration to a standard user" do
    sign_out
    sign_in_as(users(:member))

    get admin_users_path

    assert_redirected_to profile_path
  end
end
