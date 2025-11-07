require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /index" do
    context 'when user is authenticated' do
      let(:user) { create(:user) }
      
      before do
        post user_session_path, params: {
          user: { email: user.email, password: user.password }
        }
      end

      it "returns http success" do
        get dashboard_index_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not authenticated' do
      it "redirects to login" do
        get dashboard_index_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end