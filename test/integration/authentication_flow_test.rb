require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  test "visitor registers and is signed in as a regular user on /profile" do
    assert_difference "User.count", 1 do
      post registration_path, params: {
        full_name: "New Visitor",
        email_address: "visitor@iam.test",
        password: "Password123!",
        password_confirmation: "Password123!",
        avatar_url: "https://example.com/avatars/visitor.png"
      }
    end

    assert_redirected_to profile_path
    assert_equal "user", User.find_by!(email_address: "visitor@iam.test").role
    assert_includes response.cookies.keys, "session_id"

    follow_redirect!
    assert_inertia_response
    assert_inertia_component "Profile/Show"
  end

  test "visitor registers with an avatar upload instead of a URL" do
    assert_difference "User.count", 1 do
      post registration_path, params: {
        full_name: "Upload Avatar",
        email_address: "upload@iam.test",
        avatar: fixture_file_upload("avatar.png", "image/png"),
        avatar_url: "https://example.com/ignored.png",
        password: "Password123!",
        password_confirmation: "Password123!"
      }
    end

    user = User.find_by!(email_address: "upload@iam.test")
    assert user.avatar.attached?
    assert_nil user.avatar_url
    assert_redirected_to profile_path
  end

  test "registration requires an avatar source" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        full_name: "No Avatar",
        email_address: "noavatar@iam.test",
        password: "Password123!",
        password_confirmation: "Password123!"
      }
    end

    assert_inertia_response
    assert_inertia_component "Auth/Register"
    assert_inertia_props({ errors: { base: [ "Provide an avatar by upload or a remote URL" ] } })
  end

  test "registration rejects a duplicate email address" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        full_name: "Dup",
        email_address: users(:one).email_address,
        password: "Password123!",
        password_confirmation: "Password123!",
        avatar_url: "https://example.com/avatars/x.png"
      }
    end

    assert_inertia_response
    assert_inertia_component "Auth/Register"
    assert_inertia_props { |props| props.dig(:errors, :email_address).to_s.include?("taken") }
  end

  test "admin is redirected to /admin after login" do
    post session_path, params: { email_address: users(:one).email_address, password: "Password123!" }
    assert_redirected_to admin_root_path

    follow_redirect!
    assert_inertia_response
    assert_inertia_component "Admin/Dashboard"
  end

  test "regular user is redirected to /profile after login" do
    post session_path, params: { email_address: users(:two).email_address, password: "Password123!" }
    assert_redirected_to profile_path
  end

  test "non-admin is blocked from the admin area" do
    post session_path, params: { email_address: users(:two).email_address, password: "Password123!" }

    get admin_root_path
    assert_redirected_to root_path

    follow_redirect!
    assert_redirected_to profile_path
  end

  test "registration is rate limited after ten attempts" do
    params = {
      full_name: "Rate Limit",
      email_address: "ratelimit@iam.test",
      password: "Password123!",
      password_confirmation: "Password123!",
      avatar_url: "https://example.com/avatars/x.png"
    }

    10.times do
      post registration_path, params: params
      assert_not flash[:alert] == "Try again later."
    end

    post registration_path, params: params
    assert_redirected_to new_registration_path
    assert_equal "Try again later.", flash[:alert]
  end

  test "the registration page is reachable without a session" do
    get new_registration_path

    assert_inertia_response
    assert_inertia_component "Auth/Register"
  end
end
