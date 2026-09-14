require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "a visitor registers and lands on their profile" do
    visit new_registration_path

    fill_in "Full name", with: "Katherine Johnson"
    fill_in "Email", with: "katherine@umanni.test"
    fill_in "Password", with: "secret-password"
    fill_in "Confirm password", with: "secret-password"
    click_on "Create account"

    assert_current_path profile_path
    assert_text "Katherine Johnson"
    assert_text "User"
  end

  test "an admin signs in and lands on the dashboard" do
    visit new_session_path

    fill_in "Email", with: users(:admin).email
    fill_in "Password", with: "secret-password"
    click_on "Sign in"

    assert_current_path admin_dashboard_path
    assert_text "Dashboard"
  end

  test "an invalid sign in keeps the email and shows the error" do
    visit new_session_path

    fill_in "Email", with: users(:member).email
    fill_in "Password", with: "wrong"
    click_on "Sign in"

    assert_text "Try another email address or password."
    assert_field "Email", with: users(:member).email
  end
end
