require "rails_helper"

# The claim "responsive" is easy to make and easy to break: one table without a
# scroll container of its own, and the whole page scrolls sideways on a phone.
# So it is measured -- at 360 CSS pixels, which is narrower than the phones
# people actually carry.
RSpec.describe "The layout on a small screen", :js do
  let(:password) { "a-sufficiently-long-password" }
  let(:administrator) { create(:user, :admin, full_name: "Ada Lovelace", password: password) }

  def expect_no_sideways_scrolling
    overflow = page.evaluate_script(<<~JS)
      document.documentElement.scrollWidth - document.documentElement.clientWidth
    JS

    expect(overflow).to be <= 0
  end

  before do
    page.driver.resize(360, 760)

    visit new_session_path
    fill_in "Email address", with: administrator.email_address
    fill_in "Password", with: password
    click_on "Sign in"
    has_current_path?(admin_dashboard_path, wait: 5)
  end

  it "fits the sign-in screen" do
    click_on "Sign out", match: :first

    expect(page).to have_current_path(new_session_path)
    expect_no_sideways_scrolling
  end

  it "fits the dashboard" do
    expect(page).to have_text(/total users/i)
    expect_no_sideways_scrolling
  end

  it "fits the list of users, table and all" do
    create_list(:user, 3)

    visit admin_users_path

    expect(page).to have_text("Add user")
    expect_no_sideways_scrolling
  end

  it "fits a form" do
    visit new_admin_user_path

    expect(page).to have_field("Full name")
    expect_no_sideways_scrolling
  end

  it "fits the activity trail" do
    create(:audit_event, actor: administrator, subject: create(:user))

    visit admin_audit_events_path

    expect(page).to have_text(/history/i)
    expect_no_sideways_scrolling
  end
end
