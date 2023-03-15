require "rails_helper"

RSpec.describe "Sign up page", type: :system do
  # Test if a user can sign up successfully
  it "allows a user to sign up" do
    visit new_user_registration_path

    fill_in "Full Name", with: "John Doe"
    fill_in "Email", with: "john@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"

    click_button "Sign up"

    expect(page).to have_text("Welcome! You have signed up successfully.")
  end
end
