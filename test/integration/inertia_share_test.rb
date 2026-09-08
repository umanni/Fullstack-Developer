require "test_helper"

class InertiaShareTest < ActionDispatch::IntegrationTest
  test "root response shares auth user through the presenter" do
    sign_in_as users(:one)
    follow_redirect!

    assert_inertia_props auth: {
      user: {
        id: users(:one).id,
        full_name: "Ivy Admin",
        email_address: "admin@iam.test",
        role: "admin",
        avatar_source: "https://example.com/avatars/admin.png"
      }
    }
  end

  test "root response shares normalized flash after sign in" do
    post session_path, params: { email_address: users(:one).email_address, password: "Password123!" }
    follow_redirect!

    assert_inertia_response
    assert_inertia_flash notice: "Signed in successfully."
  end

  test "unauthenticated root redirects to session new" do
    get root_path

    assert_redirected_to new_session_path
  end

  private

  def sign_in_as(user)
    post session_path, params: { email_address: user.email_address, password: "Password123!" }
  end
end
