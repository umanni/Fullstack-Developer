require "rails_helper"

# The React forms check their fields in the browser (app/javascript/lib/validation.ts)
# while the user works through them, and only send what the server would accept.
RSpec.describe "Client-side form validation", :js, type: :system do
  let(:admin) { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }

  def sign_in_through_the_form(user)
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    expect(page).to have_no_current_path(new_session_path, wait: 5)
  end

  def leave(label)
    find_field(label).send_keys(:tab)
  end

  describe "registering" do
    before { visit new_registration_path }

    it "flags a field as soon as the visitor leaves it" do
      fill_in "Full name", with: "A"
      leave "Full name"

      expect(page).to have_text("is too short (minimum is 2 characters)")
      expect(find_field("Full name")["aria-invalid"]).to eq("true")
    end

    it "clears the message once the value is fixed" do
      fill_in "Email", with: "not-an-email"
      leave "Email"
      expect(page).to have_text("is invalid")

      fill_in "Email", with: "grace@example.com"

      expect(page).to have_no_text("is invalid")
    end

    it "keeps an invalid form in the browser and focuses the first problem" do
      fill_in "Full name", with: "Grace Hopper"
      fill_in "Email", with: "grace@example.com"
      fill_in "Password", with: "short"
      fill_in "Confirm password", with: "short"
      click_button "Create account"

      expect(page).to have_text("is too short (minimum is 8 characters)")
      expect(find_field("Password")).to match_css(":focus")
      expect(User.count).to eq(0)
    end
  end

  describe "the admin user form" do
    it "asks for an https avatar link before saving" do
      sign_in_through_the_form(admin)
      visit new_admin_user_path

      fill_in "Avatar URL", with: "http://example.com/avatar.png"
      leave "Avatar URL"

      expect(page).to have_text("is invalid")
    end
  end

  describe "importing a spreadsheet" do
    it "rejects a file of the wrong type as soon as it is picked" do
      sign_in_through_the_form(admin)
      visit new_admin_import_path

      attach_file "Spreadsheet", Rails.root.join("spec/fixtures/files/document.txt")

      expect(page).to have_text("must be a .csv or .xlsx file")

      click_on "Start import"

      expect(page).to have_current_path(new_admin_import_path)
      expect(Import.count).to eq(0)
    end
  end
end
