require 'rails_helper'

RSpec.describe "Admin::UserImports", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "POST /admin/user_imports/create" do
    it "accepts CSV file" do
      sign_in admin
      file = fixture_file_upload("users.csv", "text/csv")

      post admin_user_imports_path, params: { file: file }
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to eq("File imported successfully.")
    end

    it "rejects blank file" do
      sign_in admin

      post admin_user_imports_path, params: { file: nil }
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq("Please choose a file to upload.")
    end

    it "rejects wrong file type" do
      sign_in admin
      file = fixture_file_upload("not_csv.txt", "text/plain")

      post admin_user_imports_path, params: { file: file }
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq("Ivalid type file (only CSV).")
    end
  end
end
