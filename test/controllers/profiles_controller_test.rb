require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:member)
    sign_in_as(@user)
  end

  test "shows only the signed-in profile" do
    get profile_path

    assert_response :success
    assert_select "h1", @user.full_name
    assert_no_match users(:admin).email, response.body
  end

  test "renders the edit form" do
    get edit_profile_path

    assert_response :success
    assert_select "form[action='#{profile_path}']"
  end

  test "updates the signed-in profile without accepting a role" do
    patch profile_path, params: {
      user: { full_name: "Grace Updated", email: "grace.updated@example.com", role: :admin }
    }

    assert_redirected_to profile_path
    assert_equal "Grace Updated", @user.reload.full_name
    assert_predicate @user, :user?
  end

  test "renders invalid profile updates" do
    patch profile_path, params: { user: { full_name: "", email: "invalid" } }

    assert_response :unprocessable_entity
    assert_select "[role=alert]"
  end

  test "deletes the account and terminates the session" do
    assert_difference [ "User.count", "Session.count" ], -1 do
      delete profile_path
    end

    assert_redirected_to root_path
    assert_empty cookies[:session_id]
  end

  test "preserves a final administrator account" do
    sign_out
    users(:second_admin).update!(role: :user)
    sign_in_as(users(:admin))

    assert_no_difference "User.count" do
      delete profile_path
    end

    assert_redirected_to profile_path
    assert_match "last administrator", flash[:alert]
  end

  test "requires authentication" do
    sign_out

    get profile_path

    assert_redirected_to new_session_path
  end
end
