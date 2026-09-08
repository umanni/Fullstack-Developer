require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:member)
    sign_in_as(@user)
  end

  test "shows only the current profile" do
    get profile_path

    assert_response :success
    assert_inertia_component "Profile/Show"
    assert_inertia_props do |props|
      props["profile"]["id"] == @user.id && props["profile"]["email"] == @user.email
    end
  end

  test "renders profile edit" do
    get edit_profile_path

    assert_response :success
    assert_inertia_component "Profile/Edit"
  end

  test "updates permitted profile fields but cannot elevate role" do
    patch profile_path, params: {
      user: { full_name: "Updated Member", email: "updated@example.com", role: "admin" }
    }

    assert_redirected_to profile_path
    @user.reload
    assert_equal "Updated Member", @user.full_name
    assert_equal "updated@example.com", @user.email
    assert_predicate @user, :user?
  end

  test "keeps the password when blank values are submitted" do
    digest = @user.password_digest

    patch profile_path, params: {
      user: { full_name: @user.full_name, email: @user.email, password: "", password_confirmation: "" }
    }

    assert_redirected_to profile_path
    assert_equal digest, @user.reload.password_digest
  end

  test "deletes the profile and its session" do
    assert_difference "User.count", -1 do
      delete profile_path
    end

    assert_redirected_to new_registration_path
    assert_not cookies[:session_id].present?
  end

  test "requires authentication" do
    sign_out

    get profile_path

    assert_redirected_to new_session_path
  end
end
