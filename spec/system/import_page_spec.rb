require "rails_helper"

RSpec.describe "The import page", :js, type: :system do
  let(:admin) { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }

  def sign_in_through_the_form(user)
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    expect(page).to have_no_current_path(new_session_path, wait: 5)
  end

  it "shows the import's progress and tallies" do
    import = create(:import, status: :processing, total_rows: 4, processed_rows: 1, created_count: 1)
    sign_in_through_the_form(admin)

    visit admin_import_path(import)

    expect(page).to have_css("h1", text: "users.csv")
    expect(page).to have_text("1 of 4 rows (25%)")
    expect(page).to have_css("[role=progressbar][aria-valuenow='25']")
  end

  # ProcessImportJob pushes through Imports::ProgressBroadcaster; the page has to
  # pick that up over ImportChannel rather than waiting for someone to reload.
  it "follows the job's progress without a reload" do
    import = create(:import, status: :processing, total_rows: 4, processed_rows: 0)
    sign_in_through_the_form(admin)
    visit admin_import_path(import)
    expect(page).to have_text("0 of 4 rows")

    import.update_columns(status: :completed, processed_rows: 4, created_count: 3, failed_count: 1)
    Imports::ProgressBroadcaster.call(import)

    expect(page).to have_text("4 of 4 rows (100%)", wait: 5)
    expect(page).to have_text("Status: completed")
  end

  it "lists the rows that were rejected" do
    import = create(:import, status: :completed, total_rows: 2, processed_rows: 2, failed_count: 1,
                             error_report: [ { row: 2, identifier: "not-an-email",
                                               errors: [ "Email address is invalid" ] } ])
    sign_in_through_the_form(admin)

    visit admin_import_path(import)

    within("section", text: "Rejected rows") do
      expect(page).to have_text("Row 2")
      expect(page).to have_text("not-an-email")
      expect(page).to have_text("Email address is invalid")
    end
  end
end
