require "application_system_test_case"

class AdminUserManagementTest < ApplicationSystemTestCase
  test "an administrator creates, searches, promotes, and deletes a user" do
    sign_in_as_admin

    assert_text "User dashboard"
    assert_text "Total users"
    click_link "Users"
    click_link "Add user"

    fill_in "Full name", with: "Mary Jackson"
    fill_in "Email", with: "mary.jackson@example.com"
    fill_in "Remote image URL", with: "https://example.com/mary.png"
    click_button "Create user"

    assert_text "User created. Password setup instructions were queued."
    fill_in "Search by name or email", with: "mary.jackson"
    click_button "Search"
    assert_text "Mary Jackson"

    accept_confirm { click_button "Make admin" }
    assert_text "Role changed to admin."

    fill_in "Search by name or email", with: "mary.jackson"
    click_button "Search"
    accept_confirm { click_button "Delete" }

    assert_text "User deleted."
    assert_no_text "Mary Jackson"
  end

  private
    def sign_in_as_admin
      visit new_session_path
      fill_in "Email", with: users(:admin).email
      fill_in "Password", with: "SecurePass123!"
      click_button "Sign in"
    end
end
