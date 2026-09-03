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

  it "captures the import screens" do
    administrator = create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com",
                                          password: "a-sufficiently-long-password")

    import = UserImport.new(administrator: administrator, status: :completed_with_errors,
                            total_rows: 6, processed_rows: 6, created_users: 4, rejected_rows: 2)
    import.file.attach(io: Rails.root.join("spec/fixtures/files/users-with-problems.csv").open,
                       filename: "users-with-problems.csv")
    import.save!
    import.row_errors.create!(row_number: 3, email_address: nil, messages: ["Full name can't be blank"])
    import.row_errors.create!(row_number: 5, email_address: "maria@example.com",
                              messages: ["Email address has already been taken"])

    visit new_session_path
    fill_in "Email address", with: administrator.email_address
    fill_in "Password", with: "a-sufficiently-long-password"
    click_on "Sign in"
    expect(page).to have_text("Dashboard")

    visit admin_user_imports_path
    expect(page).to have_text("Imports")
    page.save_screenshot("tmp/shot-imports.png", full: true)

    visit admin_user_import_path(import)
    expect(page).to have_text("maria@example.com")
    page.save_screenshot("tmp/shot-import-detail.png", full: true)
  end
end
