require "rails_helper"

RSpec.describe "Importing users", :js, type: :system do
  include ActiveJob::TestHelper

  let(:admin)  { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }
  let(:folder) { Dir.mktmpdir("import-flow") }
  let(:team_csv) do
    spreadsheet("team.csv", <<~CSV)
      Nome,E-mail,Perfil
      Margaret Hamilton,margaret@example.com,admin
      Grace Hopper,grace@example.com,member
      Nobody,not-an-email,member
    CSV
  end

  after { FileUtils.remove_entry(folder) }

  def sign_in_through_the_form(user)
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    expect(page).to have_no_current_path(new_session_path, wait: 5)
  end

  def spreadsheet(name, content)
    File.join(folder, name).tap { |path| File.write(path, content) }
  end

  def start_import_of(file)
    sign_in_through_the_form(admin)
    visit admin_users_path
    click_on "Import users"
    attach_file "Spreadsheet", file
    click_on "Start import"
  end

  it "uploads a spreadsheet from the users page and shows it queued" do
    start_import_of(team_csv)

    expect(page).to have_css("h1", text: "team.csv")
    expect(page).to have_css("[role=status]", text: "Import queued.")
  end

  it "follows the import to the end as the job reports progress" do
    create(:user, full_name: "Grace Hopper", email_address: "grace@example.com")
    start_import_of(team_csv)
    find("h1", text: "team.csv")

    # The job runs here in the test process; the page has to hear about it over
    # ImportChannel, exactly as it would from a Solid Queue worker.
    perform_enqueued_jobs(only: ProcessImportJob)

    expect(page).to have_text("Status: completed", wait: 5)
    expect(page).to have_text("3 of 3 rows (100%)")
    within("section", text: "Rejected rows") { expect(page).to have_text("not-an-email") }
    expect(User.find_by(email_address: "margaret@example.com")).to be_admin
  end

  it "links from an import to the list of all imports" do
    start_import_of(team_csv)
    click_on "All imports"

    expect(page).to have_current_path(admin_imports_path)
    expect(page).to have_link("team.csv")
  end

  it "sends the form back when no file was chosen" do
    sign_in_through_the_form(admin)
    visit new_admin_import_path

    click_on "Start import"

    expect(page).to have_text("can't be blank")
    expect(Import.count).to eq(0)
  end

  it "lists past imports and links through to each" do
    import = create(:import, status: :completed, total_rows: 1, processed_rows: 1, created_count: 1)
    sign_in_through_the_form(admin)
    visit admin_imports_path

    within("tbody tr", text: "users.csv") { expect(page).to have_text(/completed/i) }
    click_on "users.csv"

    expect(page).to have_current_path(admin_import_path(import))
  end
end
