require "test_helper"

class ProfileManagementTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(full_name: "Me", email: "me@example.com", password: "password123", password_confirmation: "password123")
    @other = User.create!(full_name: "Other", email: "other@example.com", password: "password123", password_confirmation: "password123")
  end

  test "edit own profile" do
    sign_in_as(@user)
    get edit_profile_path
    assert_response :success

    patch profile_path, params: { user: { full_name: "Me Updated" } }
    assert_redirected_to profile_path
    assert_equal "Me Updated", @user.reload.full_name
  end

  test "delete own profile" do
    sign_in_as(@user)
    assert_difference("User.count", -1) do
      delete profile_path
    end
    assert_redirected_to new_session_path
  end
end
