require "test_helper"

class UseCaseCoverageTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(full_name: "Admin", email: "cover-admin@example.com", password: "Password123", password_confirmation: "Password123", role: :admin)
    @user = User.create!(full_name: "Cover User", email: "cover-user@example.com", password: "Password123", password_confirmation: "Password123")
  end

  # Visitor
  test "visitor redirected to login for profile and admin" do
    get profile_path
    assert_redirected_to new_session_path
    get admin_root_path
    assert_redirected_to new_session_path
    get admin_users_path
    assert_redirected_to new_session_path
  end

  test "registration rejects invalid params" do
    assert_no_difference("User.count") do
      post registration_path, params: { user: { full_name: "", email: "bad", password: "x", password_confirmation: "y" } }
    end
    assert_response :unprocessable_entity

    assert_no_difference("User.count") do
      post registration_path, params: { user: { full_name: "Dup", email: @user.email, password: "Password123", password_confirmation: "Password123" } }
    end
    assert_response :unprocessable_entity
  end

  test "login rejects wrong password" do
    post session_path, params: { email: @user.email, password: "wrongpass" }
    assert_redirected_to new_session_path
    assert_nil cookies[:session_id].presence
  end

  # User isolation
  test "profile shows own info only" do
    sign_in_as(@user)
    get profile_path
    assert_response :success
    assert_match @user.full_name, response.body
    assert_no_match @admin.email, response.body
  end

  test "profile update rejects invalid" do
    sign_in_as(@user)
    patch profile_path, params: { user: { full_name: "" } }
    assert_response :unprocessable_entity
    patch profile_path, params: { user: { email: @admin.email } }
    assert_response :unprocessable_entity
  end

  test "user cannot reach admin" do
    sign_in_as(@user)
    get admin_root_path
    assert_redirected_to root_path
    get admin_users_path
    assert_redirected_to root_path
    patch toggle_role_admin_user_path(@user)
    assert_redirected_to root_path
    assert @user.reload.user?
  end

  test "logout then profile redirects to login" do
    sign_in_as(@user)
    delete session_path
    assert_redirected_to new_session_path
    get profile_path
    assert_redirected_to new_session_path
  end

  # Admin
  test "dashboard groups by role" do
    sign_in_as(@admin)
    get admin_root_path
    assert_response :success
    assert_match "admin", response.body
    assert_match "user", response.body
  end

  test "admin create rejects duplicate" do
    sign_in_as(@admin)
    assert_no_difference("User.count") do
      post admin_users_path, params: { user: { full_name: "Dup", email: @user.email, password: "Password123", password_confirmation: "Password123" } }
    end
    assert_response :unprocessable_entity
  end

  # Model edge cases
  test "model rejects bad email and mismatch" do
    u = User.new(full_name: "X", email: "not-an-email", password: "Password123", password_confirmation: "Password123")
    assert_not u.valid?
    u2 = User.new(full_name: "X", email: "ok2@example.com", password: "Password123", password_confirmation: "different")
    assert_not u2.valid?
  end

  test "avatar can attach" do
    @user.avatar_image.attach(io: StringIO.new("x"), filename: "a.txt", content_type: "text/plain")
    assert @user.avatar_image.attached?
  end
end
