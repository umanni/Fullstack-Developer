require "rails_helper"

RSpec.describe "Registering", :js, type: :system do
  def fill_in_registration(password_confirmation: "password")
    fill_in "Full name", with: "Ada Lovelace"
    fill_in "Email", with: "ada@example.com"
    fill_in "Password", with: "password"
    fill_in "Confirm password", with: password_confirmation
  end

  it "takes a visitor from the landing page to their new profile" do
    visit root_path
    within("main") { click_on "Create account" }

    expect(page).to have_css("h1", text: "Create your account")
    fill_in_registration
    click_button "Create account"

    expect(page).to have_current_path(profile_path)
    expect(page).to have_css("h1", text: "Ada Lovelace")
    expect(User.find_by(email_address: "ada@example.com")).to be_member
  end

  it "keeps the visitor on the form with the errors shown when the details are invalid" do
    visit new_registration_path

    fill_in_registration(password_confirmation: "something-else")
    click_button "Create account"

    expect(page).to have_text("doesn't match Password")
    expect(page).to have_current_path(new_registration_path)
    expect(User.count).to eq(0)
  end

  it "is reachable from the sign-in page" do
    visit new_session_path
    click_on "Create an account"

    expect(page).to have_current_path(new_registration_path)
    expect(page).to have_css("h1", text: "Create your account")
  end

  it "reaches the sign-in page from the nav with a full page load" do
    visit root_path
    within("nav") { click_on "Sign in" }

    expect(page).to have_current_path(new_session_path)
    expect(page).to have_field("email_address")
  end
end
