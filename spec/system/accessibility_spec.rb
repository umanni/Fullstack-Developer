require "rails_helper"

# Accessibility checked rather than asserted in prose. axe runs against each
# rendered screen and fails on anything it can detect automatically: contrast,
# names, roles, labels, landmarks, heading order.
#
# Automated rules cover a part of WCAG, not all of it -- the keyboard path and
# the screen-reader wording still need a person. What is checked here is what a
# machine can honestly check.
RSpec.describe "Accessibility", :js do
  let(:password) { "a-sufficiently-long-password" }

  def sign_in_as(user)
    visit new_session_path
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: password
    click_on "Sign in"
  end

  def expect_the_page_to_be_accessible
    expect(self).to be_accessible
  end

  context "when signed out" do
    it "the sign in screen" do
      visit new_session_path

      expect_the_page_to_be_accessible
    end

    it "the sign up screen" do
      visit new_registration_path

      expect_the_page_to_be_accessible
    end

    it "the password reset request" do
      visit new_password_path

      expect_the_page_to_be_accessible
    end
  end

  context "when signed in as a regular user" do
    let(:user) { create(:user, full_name: "Maria Silva", password: password) }

    before { sign_in_as(user) }

    it "the profile" do
      expect_the_page_to_be_accessible
    end

    it "the profile form" do
      visit edit_profile_path

      expect_the_page_to_be_accessible
    end
  end

  context "when signed in as an administrator" do
    let(:administrator) { create(:user, :admin, full_name: "Ada Lovelace", password: password) }

    before do
      create_list(:user, 3)
      sign_in_as(administrator)
    end

    it "the dashboard" do
      expect_the_page_to_be_accessible
    end

    it "the list of users" do
      visit admin_users_path

      expect_the_page_to_be_accessible
    end

    it "the user form" do
      visit new_admin_user_path

      expect_the_page_to_be_accessible
    end

    it "the activity trail" do
      create(:audit_event, actor: administrator, subject: create(:user))

      visit admin_audit_events_path

      expect_the_page_to_be_accessible
    end

    it "the imports screen" do
      visit admin_user_imports_path

      expect_the_page_to_be_accessible
    end

    it "an import with rejected rows" do
      import = create(:user_import, :with_csv, administrator: administrator,
                                               status: :completed_with_errors, total_rows: 3,
                                               processed_rows: 3, created_users: 2, rejected_rows: 1)
      import.row_errors.create!(row_number: 3, email_address: "taken@example.com",
                                messages: ["Email address has already been taken"])

      visit admin_user_import_path(import)

      expect_the_page_to_be_accessible
    end
  end
end
