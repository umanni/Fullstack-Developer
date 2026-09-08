require "application_system_test_case"

class UserManagementTest < ApplicationSystemTestCase
  setup { sign_in_through_ui(users(:admin)) }

  test "administrator can navigate users and create a user" do
    click_link "Users"
    assert_current_path admin_users_path
    assert_text users(:member).full_name

    click_link "Add user"
    assert_current_path new_admin_user_path
    fill_in "Full name", with: "System Test User"
    fill_in "Email address", with: "system-test@example.com"
    fill_in "Password", with: "AValidPassword!123"
    fill_in "Confirm password", with: "AValidPassword!123"
    click_button "Create user"

    assert_current_path admin_users_path
    assert_text "System Test User"
  end

  test "administrator can open the asynchronous import workflow" do
    click_link "Imports"
    assert_current_path admin_user_imports_path
    click_link "Upload spreadsheet"

    assert_current_path new_admin_user_import_path
    assert_text "Import users"
    assert_text "CSV or XLSX"
  end
end
