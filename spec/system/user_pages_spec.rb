require "rails_helper"

RSpec.describe "The user detail pages", :js, type: :system do
  let(:admin)  { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }
  let(:member) { create(:user, full_name: "Grace Hopper", email_address: "grace@example.com") }

  def sign_in_through_the_form(user)
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    expect(page).to have_no_current_path(new_session_path, wait: 5)
  end

  describe "an admin looking at a user" do
    it "renders the user's details" do
      target = member
      sign_in_through_the_form(admin)
      visit admin_user_path(target)

      expect(page).to have_css("h1", text: "Grace Hopper")
      expect(page).to have_text("grace@example.com")
      expect(page).to have_link("Edit user", href: "/admin/users/#{target.id}/edit")
    end

    it "is reachable by clicking a name in the users table" do
      target = member
      sign_in_through_the_form(admin)
      visit admin_users_path

      click_on "Grace Hopper"

      expect(page).to have_current_path(admin_user_path(target))
      expect(page).to have_css("h1", text: "Grace Hopper")
    end
  end

  describe "a member looking at their own profile" do
    it "renders their details and a route to editing them" do
      sign_in_through_the_form(member)
      visit profile_path

      expect(page).to have_css("h1", text: "Grace Hopper")
      expect(page).to have_text("grace@example.com")
      expect(page).to have_link("Edit profile", href: "/profile/edit")
    end

    it "is reachable from the nav" do
      sign_in_through_the_form(member)
      visit edit_profile_path

      click_on "Grace Hopper"

      expect(page).to have_current_path(profile_path)
      expect(page).to have_css("h1", text: "Grace Hopper")
    end
  end
end
