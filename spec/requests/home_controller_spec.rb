require "rails_helper"

RSpec.describe "HomeController", type: :request do
  describe "GET /" do
    context "when not signed in" do
      it "renders index successfully" do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when signed in as regular user" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "redirects to profile page" do
        get root_path
        expect(response).to redirect_to(profile_path)
      end
    end

    context "when signed in as admin" do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in admin
      end

      it "redirects to admin dashboard" do
        get root_path
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end
  end
end
