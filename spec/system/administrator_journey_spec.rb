require "rails_helper"

# The administrative side from end to end: the dashboard, the list and its
# filters, the forms, and the two rules that protect the system from being left
# without anyone able to run it.
RSpec.describe "The administrator journey" do
  let(:password) { "a-sufficiently-long-password" }
  let!(:administrator) do
    create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com", password: password)
  end

  before do
    visit new_session_path
    fill_in "Email address", with: administrator.email_address
    fill_in "Password", with: password
    click_on "Sign in"
  end

  it "arrives at the dashboard and reads the counters" do
    expect(page).to have_current_path(admin_dashboard_path)
    expect(page).to have_text("Total users")
    expect(page).to have_text("Administrators")
  end

  it "creates an account on someone's behalf and finds it in the list" do
    # "Users" names the sidebar link and the dashboard button both.
    click_on "Users", match: :first
    click_on "Add user"

    fill_in "Full name", with: "Maria Silva"
    fill_in "Email address", with: "maria@example.com"
    fill_in "Password", with: password
    click_on "Create user"

    expect(page).to have_text("Maria Silva has been added.")
    expect(page).to have_text("maria@example.com")
    expect(User.find_by(email_address: "maria@example.com")).to be_user
  end

  it "narrows a long list by name and by role" do
    create(:user, full_name: "Maria Silva")
    create(:user, full_name: "João Souza")
    create(:user, :admin, full_name: "Grace Hopper")

    visit admin_users_path
    fill_in "Search", with: "maria"
    click_on "Search"

    expect(page).to have_text("Maria Silva")
    expect(page).to have_no_text("João Souza")

    click_on "Clear"
    click_on "Administrators"

    expect(page).to have_text("Grace Hopper")
    expect(page).to have_no_text("Maria Silva")
  end

  it "promotes somebody, then removes them" do
    create(:user, full_name: "Maria Silva", email_address: "maria@example.com")

    visit admin_users_path
    within("tr", text: "Maria Silva") { click_on "Edit" }
    select "Administrator", from: "Role"
    click_on "Save changes"

    expect(page).to have_text("Maria Silva has been updated.")
    expect(User.find_by(email_address: "maria@example.com")).to be_admin

    within("tr", text: "Maria Silva") { click_on "Delete" }

    expect(page).to have_text("Maria Silva has been deleted.")
  end

  it "refuses to remove the only administrator left" do
    create(:user, full_name: "Maria Silva")

    visit admin_users_path
    within("tr", text: "Ada Lovelace") { click_on "Delete" }

    expect(page).to have_text(I18n.t("activerecord.errors.models.user.attributes.base.last_administrator"))
    expect(administrator.reload).to be_persisted
  end

  it "imports a spreadsheet and reports what it did with each row", :perform_enqueued do
    click_on "Imports", match: :first
    attach_file "Spreadsheet", Rails.root.join("spec/fixtures/files/users-with-problems.csv")

    click_on "Start import"

    expect(page).to have_text(I18n.t("admin.user_imports.scheduled"))

    visit admin_user_import_path(UserImport.last)

    expect(page).to have_text("Rejected rows")
    expect(UserImport.last).to be_completed_with_errors
    expect(UserImport.last.created_users).to be_positive
  end
end
