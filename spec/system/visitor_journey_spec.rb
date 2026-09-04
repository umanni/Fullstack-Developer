require "rails_helper"

# The whole path a visitor walks, in a browser, rather than one action at a
# time: the root is a signpost, the public form only ever creates a regular
# user, and nothing behind the sign-in page is reachable before signing in.
RSpec.describe "The visitor journey" do
  it "signs up from the root and lands on their own profile" do
    visit root_path

    expect(page).to have_current_path(new_session_path)

    click_on "Create an account"
    fill_in "Full name", with: "Maria Silva"
    fill_in "Email address", with: "maria@example.com"
    fill_in "Password", with: "a-sufficiently-long-password"
    fill_in "Confirm password", with: "a-sufficiently-long-password"
    click_on "Create account"

    expect(page).to have_current_path(profile_path)
    expect(page).to have_text("Maria Silva")
    # The public form has no role field, and a hand-made request cannot add
    # one: the created account is always a regular user.
    expect(User.find_by(email_address: "maria@example.com")).to be_user
  end

  it "is stopped at the door of every page that needs an account" do
    [profile_path, edit_profile_path, admin_dashboard_path, admin_users_path,
     admin_user_imports_path].each do |path|
      visit path

      expect(page).to have_current_path(new_session_path)
    end
  end

  it "is returned to the page it asked for after signing in" do
    create(:user, :admin, email_address: "ada@example.com", password: "a-sufficiently-long-password")

    visit admin_users_path
    fill_in "Email address", with: "ada@example.com"
    fill_in "Password", with: "a-sufficiently-long-password"
    click_on "Sign in"

    expect(page).to have_current_path(admin_users_path)
  end

  it "asks for a password reset without revealing whether the account exists" do
    visit new_session_path
    click_on "Forgot password?"
    fill_in "Email address", with: "nobody@example.com"
    click_on "Send reset instructions"

    expect(page).to have_text(I18n.t("passwords.reset_instructions_sent"))
  end
end
