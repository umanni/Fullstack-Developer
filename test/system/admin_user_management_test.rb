require "application_system_test_case"

class AdminUserManagementTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:admin)
    visit admin_users_path
  end

  test "creates a user with an avatar" do
    click_on "New user"

    fill_in "Full name", with: "Katherine Johnson"
    fill_in "Email", with: "katherine@umanni.test"
    select "Admin", from: "Role"
    attach_file "Avatar", file_fixture("avatar.png")
    fill_in "user_password", with: "secret-password"
    fill_in "Confirm password", with: "secret-password"
    click_on "Create user"

    assert_text "Katherine Johnson was added."
    assert_text "katherine@umanni.test"
  end

  # minlength and type=email never reach the server; a duplicate email does.
  test "shows a server-side validation error without losing the form" do
    click_on "New user"

    fill_in "Full name", with: "Katherine Johnson"
    fill_in "Email", with: users(:member).email
    fill_in "user_password", with: "secret-password"
    fill_in "Confirm password", with: "secret-password"
    click_on "Create user"

    assert_text "Email has already been taken"
    assert_field "Full name", with: "Katherine Johnson"
  end

  test "blocks an invalid password in the browser, before any request" do
    click_on "New user"

    fill_in "user_password", with: "short"

    refute page.evaluate_script("document.getElementById('user_password').checkValidity()")
  end

  test "toggles a role in place, without a full page load" do
    fill_in "Search by name", with: "typed but not submitted"
    row = find("tr", text: "Ada Lovelace")

    within(row) { click_on "Make admin" }

    assert_text "Ada Lovelace is now an admin."
    within("tr", text: "Ada Lovelace") { assert_text "Admin" }
    # A reload would have emptied this.
    assert_field "Search by name", with: "typed but not submitted"
  end

  test "does not offer role or delete controls for the signed in admin" do
    within("tr", text: "Grace Hopper") do
      assert_text "You"
      assert_no_button "Make user"
      assert_no_button "Delete"
    end
  end

  test "searches by name" do
    fill_in "Search by name", with: "Ada"
    click_on "Filter"

    within "table" do
      assert_text "Ada Lovelace"
      assert_no_text "Grace Hopper"
    end
  end

  test "edits a user" do
    within("tr", text: "Ada Lovelace") { click_on "Edit" }

    fill_in "Full name", with: "Ada King"
    click_on "Save changes"

    assert_text "Ada King was updated."
  end

  test "deletes a user after confirming" do
    accept_confirm { within("tr", text: "Ada Lovelace") { click_on "Delete" } }

    assert_text "Ada Lovelace was removed."
    within("table") { assert_no_text "Ada Lovelace" }
  end

  # The background shorthand on .table-scroll resets background-color and takes the white
  # off the .card underneath. Nothing in the DOM changes when that happens.
  test "the users table keeps the surface of the card it sits on" do
    surface = evaluate_script("getComputedStyle(document.querySelector('.table-scroll')).backgroundColor")

    assert_not_equal "rgba(0, 0, 0, 0)", surface, "the table has no background of its own"
  end
end
