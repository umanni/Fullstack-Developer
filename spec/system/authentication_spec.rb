require "rails_helper"

RSpec.describe "Signing in", type: :system do
  let!(:user) { create(:user, email_address: "ada@example.com", password: "password") }

  it "rejects a bad password and keeps the visitor on the sign-in page" do
    visit new_session_path

    fill_in "email_address", with: "ada@example.com"
    fill_in "password", with: "wrong-password"
    click_on "Sign in"

    expect(page).to have_css("#alert", text: "Invalid email or password.")
    expect(user.sessions).to be_empty
  end

  it "signs a registered user in" do
    visit new_session_path

    fill_in "email_address", with: "ada@example.com"
    fill_in "password", with: "password"
    click_on "Sign in"

    expect(user.sessions.count).to eq(1)
  end

  it "offers a route to password recovery" do
    visit new_session_path
    click_on "Forgot password?"

    expect(page).to have_current_path(new_password_path)
  end

  # Runs through the Playwright driver registered in spec/support/capybara.rb,
  # exercising the real browser rather than rack_test.
  it "signs in through a real browser", :js do
    visit new_session_path

    fill_in "email_address", with: "ada@example.com"
    fill_in "password", with: "password"
    click_on "Sign in"

    expect(page).to have_current_path(profile_path)
    expect(user.sessions.count).to eq(1)
  end

  it "lands an admin on the user admin dashboard", :js do
    admin = create(:user, :admin, email_address: "boss@example.com", password: "password")
    visit new_session_path

    fill_in "email_address", with: "boss@example.com"
    fill_in "password", with: "password"
    click_on "Sign in"

    expect(page).to have_current_path(admin_dashboard_path)
    expect(admin.sessions.count).to eq(1)
  end
end
