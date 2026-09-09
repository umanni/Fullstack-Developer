require "rails_helper"

RSpec.describe "Admin dashboard" do
  describe "GET /admin/dashboard" do
    it "is shown to an administrator" do
      sign_in create(:user, :admin)

      get admin_dashboard_path

      expect(response).to have_http_status(:ok)
    end

    it "sends a visitor to the sign in page" do
      get admin_dashboard_path

      expect(response).to redirect_to(new_session_path)
    end

    it "refuses a regular user" do
      sign_in create(:user)

      get admin_dashboard_path

      expect(response).to redirect_to(profile_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "the counters" do
    it "shows the totals" do
      create_list(:user, 2)
      sign_in create(:user, :admin)

      get admin_dashboard_path

      expect(response.body).to include('id="user-counters"')
      expect(response.body).to include(I18n.t("admin.dashboard.total"))
    end

    it "subscribes to the stream for the reader's own locale" do
      sign_in create(:user, :admin, locale: "es")

      get admin_dashboard_path

      expect(response.body).to include("turbo-cable-stream-source")
    end
  end
end
