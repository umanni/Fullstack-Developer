require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:member) }

  test "shows the signed in user's own profile" do
    get profile_path

    assert_response :success
    assert_select "body", text: /Ada Lovelace/
  end

  test "renders the edit form" do
    get edit_profile_path

    assert_response :success
  end

  test "updates the profile" do
    patch profile_path, params: { user: { full_name: "Ada King" } }

    assert_redirected_to profile_path
    assert_equal "Ada King", users(:member).reload.full_name
  end

  test "always acts on the signed in user, never another one" do
    patch profile_path, params: { user: { full_name: "Ada King" } }

    assert_equal "Ada King", users(:member).reload.full_name
    assert_equal "Grace Hopper", users(:admin).reload.full_name
  end

  test "ignores a role the user tries to give themselves" do
    patch profile_path, params: { user: { full_name: "Ada King", role: "admin" } }

    assert_predicate users(:member).reload, :user?
  end

  test "keeps the existing password when the password fields are left blank" do
    digest = users(:member).password_digest

    patch profile_path, params: { user: { full_name: "Ada King", password: "", password_confirmation: "" } }

    assert_equal digest, users(:member).reload.password_digest
  end

  test "changes the password when a new one is given" do
    patch profile_path, params: {
      user: { password: "a-new-password", password_confirmation: "a-new-password" }
    }

    assert_predicate users(:member).reload.authenticate("a-new-password"), :present?
  end

  test "re-renders the form when the submission is invalid" do
    patch profile_path, params: { user: { email: "not-an-email" } }

    assert_response :unprocessable_content
    assert_equal "ada@umanni.test", users(:member).reload.email
  end

  test "removes an attached avatar when asked" do
    users(:member).avatar_image.attach(io: file_fixture("avatar.png").open, filename: "avatar.png")

    patch profile_path, params: { user: { remove_avatar_image: "1" } }

    assert_not users(:member).reload.avatar_image.attached?
  end

  test "keeps the avatar when the box is not ticked" do
    users(:member).avatar_image.attach(io: file_fixture("avatar.png").open, filename: "avatar.png")

    patch profile_path, params: { user: { full_name: "Ada King", remove_avatar_image: "0" } }

    assert_predicate users(:member).reload.avatar_image, :attached?
  end

  test "names the field an invalid value came from" do
    patch profile_path, params: { user: { email: "not-an-email" } }

    assert_response :unprocessable_content
    assert_select "p#email_error"
    assert_select "input[name=?][aria-invalid=true]", "user[email]"
  end

  test "attaches an avatar" do
    patch profile_path, params: { user: { avatar_image: fixture_file_upload("avatar.png", "image/png") } }

    assert_predicate users(:member).reload.avatar_image, :attached?
  end

  test "deletes the account and ends the session" do
    assert_difference -> { User.count }, -1 do
      delete profile_path
    end

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id].to_s
  end

  test "the last admin cannot delete their own account" do
    sign_out
    User.admin.where.not(id: users(:admin).id).destroy_all
    sign_in_as users(:admin)

    assert_no_difference -> { User.count } do
      delete profile_path
    end

    assert_redirected_to profile_path
    assert_equal "The only admin cannot be deleted.", flash[:alert]
  end

  test "changing the password signs every other browser out" do
    other = users(:member).sessions.create!
    mine = Current.session

    patch profile_path, params: {
      user: { password: "a-new-password", password_confirmation: "a-new-password" }
    }

    assert_nil Session.find_by(id: other.id)
    assert Session.exists?(mine.id), "the browser making the change was signed out too"
  end

  test "leaves other sessions alone when the password is untouched" do
    other = users(:member).sessions.create!

    patch profile_path, params: { user: { full_name: "Ada King" } }

    assert Session.exists?(other.id)
  end

  test "rejects a submission that is not nested under a user key" do
    patch profile_path, params: { full_name: "Ada King" }

    assert_response :bad_request
  end

  test "is closed to visitors" do
    sign_out

    get profile_path

    assert_redirected_to new_session_path
  end
end
