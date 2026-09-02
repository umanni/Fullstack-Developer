require "application_system_test_case"

class VisitorRegistrationTest < ApplicationSystemTestCase
  test "a visitor registers, edits the profile, and signs out" do
    visit root_path
    click_link "Create your account"

    fill_in "Full name", with: "Dorothy Vaughan"
    fill_in "Email", with: "dorothy@example.com"
    fill_in "Password", with: "SecurePass123!", match: :first
    fill_in "Password confirmation", with: "SecurePass123!"
    attach_file "Upload image", Rails.root.join("public/icon.png")
    assert_text "Local image selected"
    click_button "Create account"

    assert_text "Welcome! Your account is ready."
    assert_text "Dorothy Vaughan"
    assert_text "dorothy@example.com"
    assert_text(/\buser\b/i)

    click_link "Edit profile"
    fill_in "Full name", with: "Dorothy J. Vaughan"
    click_button "Save profile"

    assert_text "Your profile was updated."
    assert_text "Dorothy J. Vaughan"

    click_button "Sign out"
    assert_text "You have been signed out."
    assert_link "Create your account"
  end
end
