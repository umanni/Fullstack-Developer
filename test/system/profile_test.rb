require "application_system_test_case"

class ProfileTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:member)
    visit profile_path
  end

  test "edits the profile" do
    click_on "Edit profile"

    fill_in "Full name", with: "Ada King"
    attach_file "Avatar", file_fixture("avatar.png")
    click_on "Save changes"

    assert_text "Your profile was updated."
    assert_text "Ada King"
  end

  test "cannot reach the admin area from the profile" do
    assert_no_link "Users"
    assert_no_link "Dashboard"
  end

  test "deletes the account after confirming and lands back on sign in" do
    accept_confirm { click_on "Delete account" }

    assert_text "Your account has been deleted."
    assert_current_path new_session_path
  end
end
