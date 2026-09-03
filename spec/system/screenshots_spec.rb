require "rails_helper"

# Not a test: this captures the reference images used in the README. It asserts
# only enough to know the page rendered before the shutter fires. Excluded from
# the default run; generate the images with SCREENSHOTS=1 bin/test.
RSpec.describe "Screens", :js, :screenshots do
  it "captures the admin journey" do
    admin = create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com",
                                  password: "a-sufficiently-long-password")
    create(:user, full_name: "Maria Silva", email_address: "maria@example.com")
    create(:user, full_name: "João Souza", email_address: "joao@example.com")
    create(:user, full_name: "Lucía Fernández", email_address: "lucia@example.com")
    create(:user, :admin, full_name: "Grace Hopper", email_address: "grace@example.com")

    visit new_session_path
    fill_in "Email address", with: admin.email_address
    fill_in "Password", with: "a-sufficiently-long-password"
    click_on "Sign in"

    expect(page).to have_text("Dashboard")
    page.save_screenshot("tmp/shot-dashboard.png", full: true)

    visit admin_users_path
    expect(page).to have_text("Maria Silva")
    page.save_screenshot("tmp/shot-users.png", full: true)

    visit profile_path
    expect(page).to have_text("Ada Lovelace")
    page.save_screenshot("tmp/shot-profile.png", full: true)
  end
end
