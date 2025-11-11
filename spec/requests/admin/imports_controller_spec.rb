require "rails_helper"

RSpec.describe "Admin::ImportsController", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user) }

  before do
    sign_in admin
  end

  describe "GET /admin/imports" do
    it "returns success" do
      get admin_imports_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/imports/:id" do
    let(:import) { create(:import, user: admin) }

    it "renders HTML success" do
      get admin_import_path(import)
      expect(response).to have_http_status(:success)
    end

    it "returns JSON with correct structure" do
      get admin_import_path(import), as: :json

      json = JSON.parse(response.body)
      expect(json["id"]).to eq(import.id)
      expect(json["status"]).to eq(import.status)
      expect(json["progress"]).to eq(import.progress)
    end
  end

  describe "POST /admin/imports" do
    let(:file) do
      fixture_file_upload("spec/fixtures/files/users_valid.csv", "text/csv")
    end

    it "creates an import and enqueues job when file is provided" do
      expect {
        post admin_imports_path, params: { file: file }
      }.to change(Import, :count).by(1)

      expect(response).to redirect_to(
        admin_import_path(Import.last)
      )

      expect(flash[:notice]).to eq(
        "Import started successfully. Processing will begin shortly."
      )

      expect(UserImportJob).to have_been_enqueued.with(Import.last)
    end

    it "fails when no file is provided" do
      post admin_imports_path

      expect(response).to redirect_to(admin_imports_path)
      expect(flash[:alert]).to eq("Please select a file to import.")
    end

    it "fails when import record is invalid" do
      allow_any_instance_of(Import).to receive(:save).and_return(false)
      allow_any_instance_of(Import).to receive_message_chain(:errors, :full_messages)
        .and_return([ "Invalid import" ])

      post admin_imports_path, params: { file: file }

      expect(response).to redirect_to(admin_imports_path)
      expect(flash[:alert]).to include("Import failed: Invalid import")
    end
  end

  context "when not signed in as admin" do
    before do
      sign_out admin
      sign_in user
    end

    it "denies access" do
      get admin_imports_path
      expect(response).to redirect_to(root_path)
    end
  end
end
