require "test_helper"

class AdminUsersFlowTest < ActionDispatch::IntegrationTest
  setup do
    post session_path, params: { email_address: users(:one).email_address, password: "Password123!" }
  end

  test "dashboard shows the users overview" do
    get admin_root_path

    assert_inertia_response
    assert_inertia_component "Admin/Dashboard"
    assert_inertia_props { |props| props[:overview][:total_users] == User.count }
  end

  test "lists users with pagination props" do
    get admin_users_path

    assert_inertia_response
    assert_inertia_component "Admin/Users/Index"
    assert_inertia_props do |props|
      props[:users].length == 2 && props[:pagination][:count] == 2
    end
  end

  test "filters users by name or email" do
    get admin_users_path, params: { search: "ivy" }

    assert_inertia_props { |props| props[:users].length == 1 && props[:filters][:search] == "ivy" }
  end

  test "creates a user and redirects to the list" do
    assert_broadcasts "dashboard_stats", 1 do
      assert_difference "User.count", 1 do
        post admin_users_path, params: {
          full_name: "Dana Admin",
          email_address: "dana@iam.test",
          role: "admin",
          password: "Password123!",
          password_confirmation: "Password123!",
          avatar_url: "https://example.com/avatars/dana.png"
        }
      end
    end

    assert_redirected_to admin_users_path
    assert_equal "admin", User.find_by!(email_address: "dana@iam.test").role

    follow_redirect!
    assert_inertia_component "Admin/Users/Index"
  end

  test "create failure re-renders the new page with errors" do
    assert_no_difference "User.count" do
      post admin_users_path, params: {
        full_name: "",
        email_address: "bad@iam.test",
        role: "user",
        password: "Password123!",
        password_confirmation: "Password123!",
        avatar_url: "https://example.com/avatars/bad.png"
      }
    end

    assert_inertia_response
    assert_inertia_component "Admin/Users/New"
    assert_inertia_props { |props| props.dig(:errors, :full_name).present? }
  end

  test "edits a user without touching the password" do
    patch admin_user_path(users(:two)), params: {
      full_name: "Ursula Updated",
      email_address: users(:two).email_address,
      role: "user",
      avatar_url: users(:two).avatar_url
    }

    assert_redirected_to admin_users_path
    assert_equal "Ursula Updated", users(:two).reload.full_name
  end

  test "edits a user with a new password" do
    patch admin_user_path(users(:two)), params: {
      full_name: users(:two).full_name,
      email_address: users(:two).email_address,
      role: "user",
      avatar_url: users(:two).avatar_url,
      password: "NewPassword123!",
      password_confirmation: "NewPassword123!"
    }

    assert users(:two).reload.authenticate("NewPassword123!")
  end

  test "edit page pre-fills the current user data" do
    get edit_admin_user_path(users(:two))

    assert_inertia_props do |props|
      props.dig(:form, :full_name) == users(:two).full_name &&
        props.dig(:form, :email_address) == users(:two).email_address &&
        props.dig(:form, :role) == "user"
    end
  end

  test "deletes a regular user" do
    assert_broadcasts "dashboard_stats", 1 do
      assert_difference "User.count", -1 do
        delete admin_user_path(users(:two))
      end
    end

    assert_redirected_to admin_users_path
    assert_equal "User deleted successfully.", flash[:notice]
  end

  test "an admin cannot delete themselves" do
    assert_no_difference "User.count" do
      delete admin_user_path(users(:one))
    end

    assert_redirected_to admin_users_path
    assert_equal "You cannot delete this user.", flash[:alert]
  end

  test "toggles a user into an admin and back" do
    assert_broadcasts "dashboard_stats", 2 do
      patch toggle_role_admin_user_path(users(:two))
      assert_equal "admin", users(:two).reload.role
      patch toggle_role_admin_user_path(users(:two))
    end

    assert_equal "user", users(:two).reload.role
  end

  test "an admin cannot demote themselves" do
    patch toggle_role_admin_user_path(users(:one))

    assert_equal "admin", users(:one).reload.role
    assert_equal "You cannot change this user's role.", flash[:alert]
  end

  test "a regular user is blocked from the admin users area" do
    delete session_path
    post session_path, params: { email_address: users(:two).email_address, password: "Password123!" }

    get admin_users_path
    assert_redirected_to root_path

    post admin_users_path, params: { full_name: "Intruder", email_address: "x@iam.test", role: "user" }
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "renders the new user form" do
    get new_admin_user_path

    assert_inertia_response
    assert_inertia_component "Admin/Users/New"
    assert_inertia_props { |props| props.dig(:urls, :submit_url) == admin_users_path }
  end

  test "a failed create re-renders the new page with errors" do
    assert_no_difference "User.count" do
      post admin_users_path, params: {
        full_name: "Broken",
        email_address: users(:two).email_address,
        role: "user",
        password: "",
        avatar_url: "https://example.com/a.png"
      }
    end

    assert_inertia_response
    assert_inertia_component "Admin/Users/New"
    assert_inertia_props { |props| props.dig(:errors, :password).present? }
  end

  test "a duplicate email on create re-renders the new page with the taken error" do
    assert_no_difference "User.count" do
      post admin_users_path, params: {
        full_name: "Dup",
        email_address: users(:two).email_address,
        role: "user",
        password: "Password123!",
        password_confirmation: "Password123!",
        avatar_url: "https://example.com/a.png"
      }
    end

    assert_inertia_response
    assert_inertia_component "Admin/Users/New"
    assert_inertia_props { |props| props.dig(:errors, :email_address).to_s.include?("taken") }
  end

  test "a failed update re-renders the edit page with errors" do
    patch admin_user_path(users(:two)), params: {
      full_name: "",
      email_address: users(:two).email_address,
      role: "user",
      avatar_url: users(:two).avatar_url
    }

    assert_inertia_response
    assert_inertia_component "Admin/Users/Edit"
    assert_inertia_props { |props| props.dig(:errors, :full_name).present? }
  end
end
