require "rails_helper"

RSpec.describe "Admin::DashboardController", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user) }

  before do
    sign_in admin
  end

  describe "GET /admin/dashboard" do
    context "when service returns success" do
      let(:service_data) do
        {
          users: { total: 5, recent: [] },
          imports: { total: 10 },
          activity: { logins: 20 },
          growth: { weekly: 3 }
        }
      end

      let(:service_result) do
        double(success?: true, data: service_data)
      end

      before do
        allow(DashboardStatsService).to receive(:call).and_return(service_result)
      end

      it "returns http success" do
        get admin_dashboard_path
        expect(response).to have_http_status(:success)
      end

      it "calls the dashboard service with current_user" do
        get admin_dashboard_path
        expect(DashboardStatsService).to have_received(:call).with(admin)
      end

      it "renders the index template" do
        get admin_dashboard_path
        expect(response).to render_template(:index)
      end
    end

    context "when service returns error" do
      let(:error_result) do
        double(success?: false, error_messages: [ "Something went wrong" ])
      end

      before do
        allow(DashboardStatsService).to receive(:call).and_return(error_result)
      end

      it "redirects to root with alert" do
        get admin_dashboard_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Something went wrong")
      end
    end
  end

  context "when not admin" do
    before do
      sign_out admin
      sign_in user
    end

    it "redirects to root" do
      get admin_dashboard_path
      expect(response).to redirect_to(root_path)
    end
  end
end
