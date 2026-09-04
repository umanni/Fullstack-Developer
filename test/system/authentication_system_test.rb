require "application_system_test_case"

class AuthenticationSystemTest < ApplicationSystemTestCase
  test "member lands on profile after login" do
    sign_in_as users(:member)
    assert_current_path profile_path
    assert_text users(:member).full_name
  end

  test "admin lands on dashboard after login" do
    sign_in_as users(:admin)
    assert_current_path admin_root_path
    assert_text "Admin dashboard"
    assert_selector "[data-testid=total-users]"
  end

  test "visitor can register" do
    visit new_registration_path
    fill_in "Full name", with: "System Visitor"
    fill_in "Email", with: "system.visitor@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    click_button "Register"
    assert_current_path profile_path
    assert_text "System Visitor"
  end
end
