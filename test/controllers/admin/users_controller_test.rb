require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "lists users" do
    get admin_users_path

    assert_response :success
    assert_select "td", text: /Ada Lovelace/
  end

  test "filters by name" do
    get admin_users_path(query: "Ada")

    assert_select "td", text: /Ada Lovelace/
    assert_select "td", text: /Grace Hopper/, count: 0
  end

  test "finds a user by their exact email despite the column being encrypted" do
    get admin_users_path(query: users(:member).email.upcase)

    assert_select "td", text: /Ada Lovelace/
    assert_select "td", text: /Grace Hopper/, count: 0
  end

  test "filters by role" do
    get admin_users_path(role: "admin")

    assert_select "td", text: /Grace Hopper/
    assert_select "td", text: /Ada Lovelace/, count: 0
  end

  test "ignores a role filter that is not one of the enum values" do
    get admin_users_path(role: "'; DROP TABLE users; --")

    assert_response :success
    assert_select "td", text: /Ada Lovelace/
  end

  test "creates a user with a role of the admin's choosing" do
    assert_difference -> { User.count }, 1 do
      post admin_users_path, params: { user: valid_attributes.merge(role: "admin") }
    end

    assert_redirected_to admin_users_path
    assert_predicate User.find_by(email: "katherine@umanni.test"), :admin?
  end

  test "re-renders the form when creation is invalid" do
    assert_no_difference -> { User.count } do
      post admin_users_path, params: { user: valid_attributes.merge(email: "nope") }
    end

    assert_response :unprocessable_content
  end

  test "attaches an avatar" do
    post admin_users_path, params: { user: valid_attributes.merge(avatar_image: avatar_upload) }

    assert_predicate User.find_by(email: "katherine@umanni.test").avatar_image, :attached?
  end

  test "rejects an avatar that is not a supported image" do
    assert_no_difference -> { User.count } do
      post admin_users_path, params: {
        user: valid_attributes.merge(
          avatar_image: fixture_file_upload("not-an-image.txt", "text/plain")
        )
      }
    end

    assert_response :unprocessable_content
  end

  test "updates a user" do
    patch admin_user_path(users(:member)), params: { user: { full_name: "Ada King" } }

    assert_redirected_to admin_users_path
    assert_equal "Ada King", users(:member).reload.full_name
  end

  test "keeps the existing password when the password fields are left blank" do
    member = users(:member)
    digest = member.password_digest

    patch admin_user_path(member), params: {
      user: { full_name: "Ada King", password: "", password_confirmation: "" }
    }

    assert_equal digest, member.reload.password_digest
  end

  test "reports an error rather than silently keeping the name when it is cleared" do
    patch admin_user_path(users(:member)), params: { user: { full_name: "" } }

    assert_response :unprocessable_content
    assert_equal "Ada Lovelace", users(:member).reload.full_name
  end

  test "resetting a user's password signs them out everywhere" do
    victim = users(:member)
    victim.sessions.create!
    victim.sessions.create!

    patch admin_user_path(victim), params: {
      user: { password: "a-new-password", password_confirmation: "a-new-password" }
    }

    assert_empty victim.sessions.reload
  end

  test "deletes an admin while another one remains" do
    doomed = User.create!(full_name: "Katherine Johnson", email: "katherine@umanni.test",
                          password: "secret-password", password_confirmation: "secret-password", role: "admin")

    assert_difference -> { User.admin.count }, -1 do
      delete admin_user_path(doomed)
    end

    assert_redirected_to admin_users_path
  end

  test "deletes a user" do
    assert_difference -> { User.count }, -1 do
      delete admin_user_path(users(:member))
    end

    assert_redirected_to admin_users_path
  end

  test "does not let a query parameter rewrite the pagination links" do
    30.times { |i| User.create!(full_name: "Person #{i}", email: "p#{i}@umanni.test", password: "secret-password") }

    get "/admin/users?host=evil.example&protocol=https&page=1"

    assert_response :success
    assert_select "nav[aria-label=Pagination] a"
    assert_no_match "evil.example", response.body
  end

  # url_for only runs when there are pagination links to build, hence the rows.
  test "does not let a query parameter reach the router" do
    30.times { |i| User.create!(full_name: "Person #{i}", email: "r#{i}@umanni.test", password: "secret-password") }

    get "/admin/users?controller=sessions&action=new&page=1"

    assert_response :success
    assert_select "nav[aria-label=Pagination] a"
  end

  # A second admin, or the last-admin invariant is what blocks this and the test says
  # nothing about the parameter being stripped.
  test "an admin cannot take their own role away through the edit form" do
    User.create!(full_name: "Katherine Johnson", email: "katherine@umanni.test",
                 password: "secret-password", password_confirmation: "secret-password", role: "admin")

    patch admin_user_path(users(:admin)), params: { user: { full_name: "Grace B. Hopper", role: "user" } }

    assert_redirected_to admin_users_path
    assert_predicate users(:admin).reload, :admin?
    assert_equal "Grace B. Hopper", users(:admin).reload.full_name
  end

  # A client that follows a 302 keeps the method, and /profile answers DELETE by deleting
  # the account of whoever asked.
  test "a refusal does not hand a destructive method to the redirect target" do
    sign_out
    sign_in_as users(:member)

    delete admin_user_path(users(:admin))

    assert_response :see_other
  end

  test "every route that changes something is closed to a plain user" do
    sign_out
    sign_in_as users(:member)
    target = users(:member)

    assert_no_changes -> { [ User.count, target.reload.role, target.full_name ] } do
      post admin_users_path, params: { user: { full_name: "Mallory", email: "mallory@umanni.test",
                                               password: "secret-password", password_confirmation: "secret-password",
                                               role: "admin" } }
      patch admin_user_path(target), params: { user: { full_name: "Renamed", role: "admin" } }
      patch admin_user_role_path(target)
      delete admin_user_path(target)
    end

    assert_redirected_to profile_url
  end

  test "refuses to delete the signed in admin" do
    assert_no_difference -> { User.count } do
      delete admin_user_path(users(:admin))
    end

    assert_equal "Delete your own account from your profile.", flash[:alert]
  end

  test "rejects a submission that is not nested under a user key" do
    post admin_users_path, params: valid_attributes

    assert_response :bad_request
  end

  test "is closed to users who are not admins" do
    sign_out
    sign_in_as users(:member)

    get admin_users_path

    assert_redirected_to profile_url
  end

  test "is closed to visitors" do
    sign_out

    get admin_users_path

    assert_redirected_to new_session_path
  end

  private
    def valid_attributes
      {
        full_name: "Katherine Johnson",
        email: "katherine@umanni.test",
        password: "secret-password",
        password_confirmation: "secret-password"
      }
    end

    def avatar_upload
      fixture_file_upload("avatar.png", "image/png")
    end
end
