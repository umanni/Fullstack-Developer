require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "administrator is sent to the live dashboard after login" do
    sign_in_through_ui(users(:admin))

    assert_current_path admin_root_path
    assert_text "People overview"
    assert_text "Total users"
    assert_text "Administrators"
  end

  test "standard user is sent to their profile after login" do
    sign_in_through_ui(users(:member))

    assert_current_path profile_path
    assert_text "My profile"
    assert_text users(:member).full_name
  end

  test "a visitor can register as a standard user" do
    visit new_registration_path
    fill_in "Full name", with: "New PeopleHub User"
    fill_in "Email address", with: "new-user@example.com"
    fill_in "Password", with: "AValidPassword!123"
    fill_in "Confirm password", with: "AValidPassword!123"
    click_button "Create account"

    assert_current_path profile_path
    assert_text "New PeopleHub User"
    assert_no_text "Administration"
  end
end
