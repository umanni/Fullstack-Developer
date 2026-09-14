require "rails_helper"

RSpec.describe "The user form", :js, type: :system do
  let(:admin)  { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }
  let(:member) { create(:user, full_name: "Grace Hopper", email_address: "grace@example.com") }

  def sign_in_through_the_form(user)
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    expect(page).to have_no_current_path(new_session_path, wait: 5)
  end

  def fill_in_new_user
    fill_in "Full name", with: "Margaret Hamilton"
    fill_in "Email", with: "margaret@example.com"
    fill_in "Password", with: "password"
    fill_in "Confirm password", with: "password"
  end

  describe "an admin creating a user" do
    it "creates the user with the chosen role" do
      sign_in_through_the_form(admin)
      visit new_admin_user_path

      fill_in_new_user
      select "admin", from: "Role"
      click_on "Create user"

      expect(page).to have_css("[role=status]", text: "Margaret Hamilton was created.")
      expect(User.find_by(email_address: "margaret@example.com")).to be_admin
    end

    it "attaches an uploaded avatar" do
      sign_in_through_the_form(admin)
      visit new_admin_user_path

      fill_in_new_user
      attach_file "Avatar upload", Rails.root.join("spec/fixtures/files/avatar.png")
      click_on "Create user"

      expect(page).to have_css("[role=status]", text: "Margaret Hamilton was created.")
      expect(User.find_by(email_address: "margaret@example.com").avatar_image).to be_attached
    end

    it "shows validation errors on the form" do
      sign_in_through_the_form(admin)
      visit new_admin_user_path

      fill_in "Email", with: "margaret@example.com"
      click_on "Create user"

      expect(page).to have_text("can't be blank")
      expect(User.find_by(email_address: "margaret@example.com")).to be_nil
    end
  end

  describe "an admin editing a user" do
    it "keeps the current avatar when no new file is picked" do
      target = create(:user, :with_avatar_image, full_name: "Grace Hopper", email_address: "grace@example.com")
      sign_in_through_the_form(admin)
      visit edit_admin_user_path(target)

      fill_in "Full name", with: "Grace M. Hopper"
      click_on "Save changes"

      expect(page).to have_css("[role=status]", text: "Grace M. Hopper was updated.")
      expect(target.reload.avatar_image).to be_attached
    end
  end

  describe "a member editing their profile" do
    it "saves the change" do
      sign_in_through_the_form(member)
      visit edit_profile_path

      fill_in "Full name", with: "Grace M. Hopper"
      click_on "Save changes"

      expect(page).to have_css("[role=status]", text: "Profile updated.")
      expect(member.reload.full_name).to eq("Grace M. Hopper")
    end
  end
end
