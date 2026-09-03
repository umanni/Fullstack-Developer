require "rails_helper"

RSpec.describe "Signing in", :js do
  it "takes an administrator to the dashboard" do
    create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com",
                          password: "a-sufficiently-long-password")

    visit new_session_path
    fill_in "Email address", with: "ada@example.com"
    fill_in "Password", with: "a-sufficiently-long-password"
    click_on "Sign in"

    expect(page).to have_current_path(admin_dashboard_path)
    expect(page).to have_text("Ada Lovelace")
  end

  it "takes a regular user to their profile" do
    create(:user, full_name: "Maria Silva", email_address: "maria@example.com",
                  password: "a-sufficiently-long-password")

    visit new_session_path
    fill_in "Email address", with: "maria@example.com"
    fill_in "Password", with: "a-sufficiently-long-password"
    click_on "Sign in"

    expect(page).to have_current_path(profile_path)
    expect(page).to have_text("Maria Silva")
  end

  it "keeps the visitor on the form when the password is wrong" do
    create(:user, email_address: "maria@example.com")

    visit new_session_path
    fill_in "Email address", with: "maria@example.com"
    fill_in "Password", with: "wrong password"
    click_on "Sign in"

    expect(page).to have_current_path(new_session_path)
    expect(page).to have_text(I18n.t("sessions.invalid_credentials"))
  end

  it "switches the interface language from the flag picker" do
    visit new_session_path

    click_on "Português"

    expect(page).to have_text("Entrar")
    expect(page).to have_field("E-mail")
  end
end
