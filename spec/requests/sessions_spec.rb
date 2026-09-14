require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:password) { "password" }
  let!(:user) { create(:user, email_address: "ada@example.com", password: password) }

  describe "GET /session/new" do
    it "is reachable without authentication" do
      get new_session_url

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sign in")
    end
  end

  describe "POST /session" do
    it "signs a member in and lands them on their profile" do
      post session_url, params: { email_address: "ada@example.com", password: password }

      expect(response).to redirect_to(profile_path)
      expect(user.sessions.count).to eq(1)
    end

    it "lands an admin on the admin dashboard instead" do
      admin = create(:user, :admin, email_address: "boss@example.com", password: password)

      post session_url, params: { email_address: "boss@example.com", password: password }

      expect(response).to redirect_to(admin_dashboard_path)
      expect(admin.sessions.count).to eq(1)
    end

    it "accepts an address that needs normalizing" do
      post session_url, params: { email_address: "  ADA@Example.COM ", password: password }

      expect(response).to redirect_to(profile_path)
      expect(user.sessions.count).to eq(1)
    end

    it "records the request metadata on the new session" do
      post session_url,
           params: { email_address: "ada@example.com", password: password },
           headers: { "HTTP_USER_AGENT" => "RSpec UA" }

      session = user.sessions.sole
      expect(session.user_agent).to eq("RSpec UA")
      expect(session.ip_address).to be_present
    end

    it "rejects a wrong password without creating a session" do
      post session_url, params: { email_address: "ada@example.com", password: "wrong" }

      expect(response).to redirect_to(new_session_url)
      expect(flash[:alert]).to include('Invalid email or password')
      expect(user.sessions).to be_empty
    end

    it "rejects an unknown address without revealing that it is unknown" do
      post session_url, params: { email_address: "nobody@example.com", password: password }

      expect(response).to redirect_to(new_session_url)
      expect(flash[:alert]).to include('Invalid email or password')
    end

    it "returns the user to the page they originally requested, ahead of the default landing page" do
      get edit_profile_url # bounced to sign-in, stashing the destination
      post session_url, params: { email_address: "ada@example.com", password: password }

      expect(response).to redirect_to(edit_profile_url)
    end
  end

  describe "DELETE /session" do
    it "signs the user out and drops the session record" do
      sign_in_as(user)
      expect(user.sessions.count).to eq(1)

      delete session_url

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(new_session_url)
      expect(user.sessions).to be_empty
    end

    it "answers an Inertia request with a location visit rather than a redirect" do
      sign_in_as(user)

      delete session_url, headers: { "X-Inertia" => "true" }

      expect(response).to have_http_status(:conflict)
      expect(response.headers["X-Inertia-Location"]).to eq(new_session_path)
      expect(user.sessions).to be_empty
    end

    it "requires authentication" do
      delete session_url

      expect(response).to redirect_to(new_session_url)
    end
  end

  describe "authentication guard" do
    it "redirects a signed-out visitor away from a protected page" do
      get profile_url

      expect(response).to redirect_to(new_session_url)
    end

    it "lets a signed-in user through" do
      sign_in_as(user)

      get profile_url

      expect(response).to have_http_status(:ok)
    end
  end
end
