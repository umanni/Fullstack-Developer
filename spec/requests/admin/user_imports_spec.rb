require "rails_helper"

RSpec.describe "Admin user imports" do
  let(:administrator) { create(:user, :admin) }

  def upload(name, content_type: "text/csv")
    Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/#{name}"), content_type)
  end

  before { sign_in administrator }

  describe "GET /admin/user_imports" do
    it "lists previous imports, newest first" do
      older = create(:user_import, :with_csv, administrator: administrator, created_at: 2.days.ago)
      newer = create(:user_import, :with_csv, administrator: administrator)

      get admin_user_imports_path

      expect(response).to have_http_status(:ok)
      expect(response.body.index(admin_user_import_path(newer)))
        .to be < response.body.index(admin_user_import_path(older))
    end
  end

  describe "POST /admin/user_imports" do
    it "accepts a CSV and schedules the work" do
      expect { post admin_user_imports_path, params: { user_import: { file: upload("users.csv") } } }
        .to change(UserImport, :count).by(1)
        .and have_enqueued_job(ProcessUserImportJob)

      expect(response).to redirect_to(admin_user_import_path(UserImport.last))
    end

    it "records who asked for it" do
      post admin_user_imports_path, params: { user_import: { file: upload("users.csv") } }

      expect(UserImport.last.administrator).to eq(administrator)
    end

    it "refuses a file it cannot parse, without scheduling anything" do
      expect do
        post admin_user_imports_path,
             params: { user_import: { file: upload("avatar.png", content_type: "image/png") } }
      end.not_to have_enqueued_job(ProcessUserImportJob)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /admin/user_imports/:id" do
    it "shows the progress and the rejected rows" do
      import = create(:user_import, :with_csv, administrator: administrator,
                                               status: :completed_with_errors, total_rows: 2,
                                               processed_rows: 2, created_users: 1, rejected_rows: 1)
      import.row_errors.create!(row_number: 3, email_address: "bad@example.com", messages: ["Email is invalid"])

      get admin_user_import_path(import)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("bad@example.com")
      expect(response.body).to include("Email is invalid")
    end
  end

  describe "GET /admin/user_imports/template.csv" do
    it "offers a template carrying the expected header" do
      get template_admin_user_imports_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("full_name,email,avatar_url,role")
      expect(response.headers["Content-Disposition"]).to include("attachment")
    end

    it "is a file the importer itself can read back" do
      get template_admin_user_imports_path(format: :csv)
      path = Rails.root.join("tmp/template-roundtrip.csv")
      path.write(response.body)

      parser = UserImportParser.new(path: path.to_s, format: :csv)

      expect(parser.row_count).to be_positive
    ensure
      path&.delete if path&.exist?
    end
  end

  describe "GET /admin/user_imports/:id/rejected_rows.csv" do
    it "neutralises a cell that a spreadsheet would treat as a formula" do
      import = create(:user_import, :with_csv, administrator: administrator)
      import.row_errors.create!(row_number: 2, email_address: "=cmd|'/c calc'!A1",
                                messages: ["@SUM(1+1)"])

      get rejected_rows_admin_user_import_path(import, format: :csv)

      expect(response.body).to include("'=cmd")
      expect(response.body).to include("'@SUM")
      expect(response.body).not_to match(/^=cmd/)
    end
  end

  describe "authorization" do
    it "keeps a regular user out of every action" do
      sign_in create(:user)
      import = create(:user_import, :with_csv, administrator: administrator)

      get admin_user_imports_path
      expect(response).to redirect_to(profile_path)

      get admin_user_import_path(import)
      expect(response).to redirect_to(profile_path)

      expect do
        post admin_user_imports_path, params: { user_import: { file: upload("users.csv") } }
      end.not_to change(UserImport, :count)
    end
  end
end
