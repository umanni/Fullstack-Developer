require 'rails_helper'

RSpec.describe "UserSignups", type: :system do
  before do
    driven_by(:rack_test) # Use this for fast, headless tests
    # driven_by(:selenium_chrome_headless) # Use this if you need JavaScript
  end

  it "allows a visitor to sign up" do
    visit root_path

    # From the navbar
    click_on "Sign Up"

    expect(page).to have_content("Sign up")

    fill_in "Full name", with: "Test User"
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"

    click_button "Sign up"

    # Should redirect to the profile page
    expect(page).to have_content("My Profile")
    expect(page).to have_content("Test User")
    expect(User.last.email).to eq("test@example.com")
  end
end
