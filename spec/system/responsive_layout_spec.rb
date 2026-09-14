require "rails_helper"

RSpec.describe "The layout on a phone", :js, type: :system do
  let(:admin) { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }
  # Long names and addresses, the text most likely to push a phone layout sideways.
  let(:member) do
    create(:user, full_name: "Grace Brewster Murray Hopper",
                  email_address: "grace.brewster.murray.hopper@navy.example.com")
  end
  let(:import) do
    create(:import, status: :completed, total_rows: 1, processed_rows: 1, failed_count: 1,
                    error_report: [ { row: 1, identifier: "an-unusually-long-address-for-a-phone@example.com",
                                      errors: [ "Email address is invalid" ] } ])
  end

  # iPhone-sized viewport. The window outlives the example, so put it back.
  before { page.current_window.resize_to(390, 844) }
  after  { page.current_window.resize_to(1280, 800) }

  def sign_in_through_the_form(user)
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    expect(page).to have_no_current_path(new_session_path, wait: 5)
  end

  def sideways_overflow = page.evaluate_script("document.documentElement.scrollWidth - window.innerWidth")

  it "fits the sign-in page and every signed-in page to the screen" do
    visit new_session_path
    expect(sideways_overflow).to be <= 0

    sign_in_through_the_form(admin)

    [
      admin_dashboard_path, admin_users_path, admin_user_path(member), edit_admin_user_path(member),
      new_admin_user_path, admin_imports_path, new_admin_import_path, admin_import_path(import),
      profile_path, edit_profile_path
    ].each do |path|
      visit path
      expect(page).to have_css("h1")
      expect(sideways_overflow).to be <= 0, "#{path} scrolls sideways by #{sideways_overflow}px"
    end
  end

  it "folds the navigation into a menu that closes after a visit" do
    sign_in_through_the_form(admin)
    visit admin_dashboard_path

    expect(page).to have_no_link("Users")

    click_on "Open menu"
    click_on "Users"

    expect(page).to have_current_path(admin_users_path)
    expect(page).to have_no_button("Sign out")
    expect(page).to have_button("Open menu")
  end
end
