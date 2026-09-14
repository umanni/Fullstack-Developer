require "rails_helper"

RSpec.describe "The application layout", :js, type: :system do
  let(:member) { create(:user, full_name: "Grace Hopper", email_address: "grace@example.com") }
  let(:admin)  { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }

  def sign_in_through_the_form(user)
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    # `click_on` returns before the redirect lands, so wait it out rather than
    # asserting against the sign-in page we are still standing on.
    expect(page).to have_no_current_path(new_session_path, wait: 5)
  end

  it "gives a visitor ways to sign in and register, and no signed-in links" do
    visit root_path

    expect(page).to have_link("Sign in", href: "/session/new")
    expect(page).to have_link("Create account", href: "/registration/new")
    expect(page).to have_no_button("Sign out")
  end

  it "gives a member their own name and no admin links" do
    sign_in_through_the_form(member)
    visit profile_path

    expect(page).to have_link("Grace Hopper", href: "/profile")
    expect(page).to have_no_link("Dashboard")
    expect(page).to have_no_link("Users")
  end

  it "gives an admin the dashboard and users links" do
    sign_in_through_the_form(admin)
    visit admin_dashboard_path

    expect(page).to have_link("Dashboard", href: "/admin")
    expect(page).to have_link("Users", href: "/admin/users")
    expect(page).to have_link("Ada Lovelace", href: "/profile")
  end

  it "sends a member who opens the root to their profile" do
    sign_in_through_the_form(member)
    visit root_path

    expect(page).to have_current_path(profile_path)
    expect(page).to have_css("h1", text: "Grace Hopper")
  end

  it "sends an admin who opens the root to the dashboard" do
    sign_in_through_the_form(admin)
    visit root_path

    expect(page).to have_current_path(admin_dashboard_path)
  end

  it "destroys the session when Sign out is clicked" do
    sign_in_through_the_form(member)
    visit profile_path

    click_on "Sign out"

    expect(page).to have_current_path(new_session_path)
    expect(member.sessions.reload).to be_empty
  end

  it "leaves the nav showing no signed-in user after signing out" do
    sign_in_through_the_form(member)
    visit profile_path

    click_on "Sign out"

    expect(page).to have_current_path(new_session_path)
    expect(page).to have_no_link("Grace Hopper")
  end

  it "renders a flash alert in the banner" do
    sign_in_through_the_form(member)
    visit admin_users_path # denied, bounced to the root, and on to the member's profile

    expect(page).to have_current_path(profile_path)
    expect(page).to have_css("[role=status]", text: "You are not authorized to do that.")
  end

  it "keeps the banner styled for an alert rather than a notice" do
    sign_in_through_the_form(member)
    visit admin_users_path

    expect(page).to have_css("[role=status].bg-red-50")
    expect(page).to have_no_css("[role=status].bg-emerald-50")
  end

  it "shows no banner on a plain page load" do
    sign_in_through_the_form(member)
    visit profile_path

    expect(page).to have_css("h1", text: "Grace Hopper")
    expect(page).to have_no_css("[role=status]")
  end
end
