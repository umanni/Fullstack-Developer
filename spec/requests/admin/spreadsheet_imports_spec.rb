require "rails_helper"

RSpec.describe "Admin::SpreadsheetImports", type: :request do
  let(:admin) { create(:user, :admin, password: "password123") }
  let(:csv_file) { fixture_file_upload("valid_import.csv", "text/csv") }

  describe "GET /admin/spreadsheet_imports" do
    it "redirects unauthenticated visitors to sign in" do
      get admin_spreadsheet_imports_path

      expect(response).to redirect_to(new_session_path)
    end

    it "redirects a no_admin user to their profile" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      get admin_spreadsheet_imports_path

      expect(response).to redirect_to(profile_url)
    end

    it "lists imports for an admin" do
      spreadsheet_import = create(:spreadsheet_import)
      sign_in_as(admin)

      get admin_spreadsheet_imports_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(spreadsheet_import.file.filename.to_s)
    end
  end

  describe "GET /admin/spreadsheet_imports/new" do
    it "is forbidden for a no_admin user" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      get new_admin_spreadsheet_import_path

      expect(response).to redirect_to(profile_url)
    end

    it "is accessible to an admin" do
      sign_in_as(admin)

      get new_admin_spreadsheet_import_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/spreadsheet_imports" do
    it "uploads a spreadsheet, enqueues the import job and redirects to its progress page" do
      sign_in_as(admin)

      expect {
        post admin_spreadsheet_imports_path, params: { spreadsheet_import: { file: csv_file } }
      }.to change(SpreadsheetImport, :count).by(1).and have_enqueued_job(SpreadsheetImportJob)

      spreadsheet_import = SpreadsheetImport.last
      expect(spreadsheet_import.user).to eq(admin)
      expect(response).to redirect_to(admin_spreadsheet_import_url(spreadsheet_import))
    end

    it "accepts the has_header flag" do
      sign_in_as(admin)

      post admin_spreadsheet_imports_path, params: { spreadsheet_import: { file: csv_file, has_header: false } }

      expect(SpreadsheetImport.last.has_header).to be false
    end

    it "re-renders the form when no file is attached" do
      sign_in_as(admin)

      expect {
        post admin_spreadsheet_imports_path, params: { spreadsheet_import: { file: "" } }
      }.not_to change(SpreadsheetImport, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "is forbidden for a no_admin user" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      expect {
        post admin_spreadsheet_imports_path, params: { spreadsheet_import: { file: csv_file } }
      }.not_to change(SpreadsheetImport, :count)

      expect(response).to redirect_to(profile_url)
    end
  end

  describe "GET /admin/spreadsheet_imports/:id" do
    it "shows the import's progress to an admin" do
      spreadsheet_import = create(:spreadsheet_import)
      sign_in_as(admin)

      get admin_spreadsheet_import_path(spreadsheet_import)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("linhas processadas")
    end

    it "is forbidden for a no_admin user" do
      spreadsheet_import = create(:spreadsheet_import)
      user = create(:user, password: "password123")
      sign_in_as(user)

      get admin_spreadsheet_import_path(spreadsheet_import)

      expect(response).to redirect_to(profile_url)
    end
  end
end
