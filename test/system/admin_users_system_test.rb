require "application_system_test_case"

class AdminUsersSystemTest < ApplicationSystemTestCase
  test "admin can create and toggle a user" do
    sign_in_as users(:admin)

    visit new_admin_user_path
    assert_selector "h1", text: "New user"

    fill_in "user_full_name", with: "System Created"
    fill_in "user_email_address", with: "system.created@example.com"
    fill_in "user_password", with: "password123"
    fill_in "user_password_confirmation", with: "password123"
    select "Member", from: "user_role"
    click_button "Create user"

    assert_text "User created."
    visit admin_users_path
    assert_text "System Created"

    user = User.find_by!(email_address: "system.created@example.com")
    within("#user_#{user.id}") do
      click_button "Admin"
    end
    assert_text "was changed from member to admin"
  end
end
