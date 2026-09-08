require "test_helper"

class ProfileFlowTest < ActionDispatch::IntegrationTest
  setup do
    post session_path, params: { email_address: users(:two).email_address, password: "Password123!" }
  end

  test "shows the own profile through the presenter" do
    get profile_path

    assert_inertia_response
    assert_inertia_component "Profile/Show"
    assert_inertia_props { |props| props[:user][:email_address] == users(:two).email_address }
  end

  test "edit page pre-fills the profile" do
    get edit_profile_path

    assert_inertia_props do |props|
      props.dig(:form, :full_name) == users(:two).full_name &&
        props.dig(:form, :email_address) == users(:two).email_address
    end
  end

  test "updates the profile" do
    patch profile_path, params: {
      full_name: "Ursula Renamed",
      email_address: "renamed@iam.test",
      avatar_url: users(:two).avatar_url
    }

    assert_redirected_to profile_path
    assert_equal "Ursula Renamed", users(:two).reload.full_name
    assert_equal "renamed@iam.test", users(:two).reload.email_address
  end

  test "updates the password without touching the profile fields" do
    patch profile_path, params: {
      full_name: users(:two).full_name,
      email_address: users(:two).email_address,
      avatar_url: users(:two).avatar_url,
      password: "NewPassword123!",
      password_confirmation: "NewPassword123!"
    }

    assert users(:two).reload.authenticate("NewPassword123!")
    assert_redirected_to profile_path
  end

  test "update failure re-renders edit with errors keeping the form" do
    patch profile_path, params: {
      full_name: "",
      email_address: users(:two).email_address,
      avatar_url: users(:two).avatar_url
    }

    assert_inertia_response
    assert_inertia_component "Profile/Edit"
    assert_inertia_props { |props| props.dig(:errors, :full_name).present? }
  end

  test "anti-IDOR: a foreign id param is ignored" do
    patch profile_path, params: {
      id: users(:one).id,
      full_name: "Hacked Name",
      email_address: users(:two).email_address,
      avatar_url: users(:two).avatar_url
    }

    assert_equal "Hacked Name", users(:two).reload.full_name
    assert_equal "Ivy Admin", users(:one).reload.full_name
  end

  test "deletes the account, ends the session and returns to login" do
    assert_difference "User.count", -1 do
      delete profile_path
    end

    assert_redirected_to new_session_path
    refute cookies[:session_id].present?
    assert_equal "Your account has been closed. Goodbye!", flash[:notice]
    assert_no_difference "Session.count" do
      get profile_path
    end
  end

  test "requires authentication for the profile area" do
    delete session_path

    get profile_path
    assert_redirected_to new_session_path

    get edit_profile_path
    assert_redirected_to new_session_path
  end
end
