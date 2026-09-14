require "rails_helper"

RSpec.describe "The admin dashboard", :js, type: :system do
  let(:admin) { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }

  def sign_in_through_the_form(user)
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    expect(page).to have_no_current_path(new_session_path, wait: 5)
  end

  it "is where an admin lands after signing in" do
    sign_in_through_the_form(admin)

    expect(page).to have_current_path(admin_dashboard_path)
    expect(page).to have_css("h1", text: "Admin dashboard")
  end

  it "shows the total and the count per role" do
    create_list(:user, 2)
    sign_in_through_the_form(admin)

    expect(page).to have_css("dt", text: /Total users/i)
    expect(page).to have_css("dd", text: "3")
    expect(page).to have_css("dt", text: /Admins/i)
    expect(page).to have_css("dt", text: /Members/i)
  end

  it "updates the counts when a user is created elsewhere" do
    sign_in_through_the_form(admin)
    total = -> { find("dt", text: /Total users/i).sibling("dd") }

    expect(total.call).to have_text("1")

    create(:user)

    expect(total.call).to have_text("2", wait: 5)
  end

  it "links through to the users table" do
    sign_in_through_the_form(admin)

    click_on "Manage users"

    expect(page).to have_current_path(admin_users_path)
  end
end
