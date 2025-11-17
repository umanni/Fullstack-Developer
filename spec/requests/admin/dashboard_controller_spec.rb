require 'rails_helper'

RSpec.describe "Admin::DashboarController", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user) }
  describe "authentication and authorization" do
    it "redirects to login when not signed in" do
      get admin_dashboard_index_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "denies access to non-admin users" do
      sign_in user

      get admin_dashboard_index_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Access denied.")
    end

    it "allows admin users" do
      sign_in admin

      get admin_dashboard_index_path
      expect(response).to have_http_status(:success)
    end
  end
end
