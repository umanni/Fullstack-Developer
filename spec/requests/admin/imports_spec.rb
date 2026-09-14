require "rails_helper"

RSpec.describe "Admin::Imports", type: :request do
  def props = inertia.props.deep_symbolize_keys

  def upload(name = "users.csv", type = "text/csv") = fixture_file_upload(name, type)

  let(:admin)  { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }
  let(:member) { create(:user, full_name: "Grace Hopper", email_address: "grace@example.com") }

  describe "GET /admin/imports" do
    it "turns away a visitor who is not signed in" do
      get admin_imports_path

      expect(response).to redirect_to(new_session_url)
    end

    it "turns away a member with the authorization alert" do
      sign_in_as(member)

      get admin_imports_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to do that.")
    end

    it "lists imports newest first for an admin" do
      older = create(:import, created_at: 2.days.ago)
      newer = create(:import, created_at: 1.hour.ago)
      sign_in_as(admin)

      get admin_imports_path

      expect(inertia).to render_component("Admin/Imports/Index")
      expect(props[:imports].pluck(:id)).to eq([ newer.id, older.id ])
    end

    it "lists no more than the 25 most recent" do
      create_list(:import, 26)
      sign_in_as(admin)

      get admin_imports_path

      expect(props[:imports].size).to eq(25)
    end
  end

  describe "GET /admin/imports/new" do
    it "renders the upload form for an admin" do
      sign_in_as(admin)

      get new_admin_import_path

      expect(inertia).to render_component("Admin/Imports/New")
    end

    it "is closed to members" do
      sign_in_as(member)

      get new_admin_import_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /admin/imports/:id" do
    it "renders the import for an admin" do
      import = create(:import, status: :processing, total_rows: 10, processed_rows: 5)
      sign_in_as(admin)

      get admin_import_path(import)

      expect(inertia).to render_component("Admin/Imports/Show")
      expect(props[:import]).to include(id: import.id, status: "processing", progress: 50)
    end

    it "is closed to members" do
      import = create(:import)
      sign_in_as(member)

      get admin_import_path(import)

      expect(response).to redirect_to(root_path)
    end

    it "responds not found for an import that does not exist" do
      sign_in_as(admin)

      get admin_import_path(0)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /admin/imports" do
    it "saves the upload against the admin and queues it" do
      sign_in_as(admin)

      expect { post admin_imports_path, params: { import: { file: upload } } }
        .to change(admin.imports, :count).by(1)

      import = admin.imports.last
      expect(ProcessImportJob).to have_been_enqueued.with(import)
      expect(import.file.filename.to_s).to eq("users.csv")
    end

    it "shows the queued import's page" do
      sign_in_as(admin)

      post admin_imports_path, params: { import: { file: upload } }

      expect(response).to redirect_to(admin_import_path(admin.imports.last))
      expect(flash[:notice]).to eq("Import queued.")
    end

    it "sends a file of the wrong type back to the form with the reason" do
      sign_in_as(admin)

      expect { post admin_imports_path, params: { import: { file: upload("document.txt", "text/plain") } } }
        .not_to change(Import, :count)

      expect(response).to redirect_to(new_admin_import_path)
      expect(session[:inertia_errors][:file]).to include("must be a .csv or .xlsx file")
      expect(ProcessImportJob).not_to have_been_enqueued
    end

    it "sends a submission without a file back to the form" do
      sign_in_as(admin)

      expect { post admin_imports_path, params: { import: { file: "" } } }.not_to change(Import, :count)

      expect(session[:inertia_errors][:file]).to include("can't be blank")
    end

    it "is closed to members and queues nothing" do
      sign_in_as(member)

      expect { post admin_imports_path, params: { import: { file: upload } } }.not_to change(Import, :count)

      expect(response).to redirect_to(root_path)
      expect(ProcessImportJob).not_to have_been_enqueued
    end
  end
end
