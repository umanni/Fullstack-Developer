require "rails_helper"

RSpec.describe "Home", type: :request do
  let(:member) { create(:user, email_address: "grace@example.com", password: "password") }
  let(:admin)  { create(:user, :admin, email_address: "boss@example.com", password: "password") }

  describe "GET /" do
    it "shows a visitor the landing page rather than bouncing them to sign in" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(inertia).to render_component("home/index")
      expect(inertia.props.deep_symbolize_keys[:auth]).to eq(user: nil)
    end

    it "sends a signed-in member to their profile" do
      sign_in_as(member)

      get root_path

      expect(response).to redirect_to(profile_path)
    end

    it "sends a signed-in admin to the user admin dashboard" do
      sign_in_as(admin)

      get root_path

      expect(response).to redirect_to(admin_dashboard_path)
    end

    it "treats a visitor whose session was revoked as signed out" do
      sign_in_as(member)
      member.sessions.destroy_all

      get root_path

      expect(inertia).to render_component("home/index")
    end

    it "carries a flash through to the page it forwards to" do
      sign_in_as(member)

      get admin_dashboard_path # denied, and bounced to the root
      follow_redirect!         # which forwards the member on to their profile
      follow_redirect!

      expect(request.path).to eq(profile_path)
      expect(inertia.props.deep_symbolize_keys[:flash]).to include(alert: "You are not authorized to do that.")
    end

    it "is not remembered as the page to return to, so signing in still lands by role" do
      get root_path
      post session_url, params: { email_address: admin.email_address, password: "password" }

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end
end
