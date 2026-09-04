require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:member) }

  test "member can view own profile" do
    get profile_url
    assert_response :success
    assert_select "h1", users(:member).full_name
  end

  test "member can update own profile" do
    patch profile_url, params: { user: { full_name: "Morgan Updated" } }
    assert_redirected_to profile_url
    assert_equal "Morgan Updated", users(:member).reload.full_name
  end

  test "member can delete own profile" do
    assert_difference("User.count", -1) do
      delete profile_url
    end
    assert_redirected_to new_session_url
  end
end
