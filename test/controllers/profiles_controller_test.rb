require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:member)
  end

  test "member can view own profile" do
    get profile_url
    assert_response :success
    assert_match users(:member).full_name, response.body
  end

  test "member can update own profile" do
    patch profile_url, params: { user: { full_name: "Updated Name" } }
    assert_redirected_to profile_url
    assert_equal "Updated Name", users(:member).reload.full_name
  end

  test "member can delete own profile" do
    assert_difference("User.count", -1) do
      delete profile_url
    end
    assert_redirected_to new_session_url
  end
end
