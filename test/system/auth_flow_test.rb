require "application_system_test_case"

class AuthFlowTest < ApplicationSystemTestCase
  test "visitor signs up and lands on profile" do
    visit "/registration/new"
    fill_in placeholder: "Full name", with: "System Newbie"
    fill_in placeholder: "Email", with: "sys-newbie@example.com"
    fill_in placeholder: "Password", with: "password123"
    fill_in placeholder: "Confirm password", with: "password123"
    click_on "Create account"

    assert_current_path "/profile"
    assert_text "My Profile"
    assert_text "System Newbie"
  end

  test "admin signs in and sees live dashboard" do
    User.create!(full_name: "Sys Admin", email: "sys-admin@example.com", password: "password123", password_confirmation: "password123", role: :admin)

    visit "/session/new"
    fill_in placeholder: "Enter your email address", with: "sys-admin@example.com"
    fill_in placeholder: "Enter your password", with: "password123"
    within("form") { click_on "Sign in" }

    assert_current_path "/admin"
    assert_text "User Admin Dashboard"
    assert_text "Total number of Users"
  end
end
