require "rails_helper"

RSpec.describe "Security", type: :request do
  describe "SQL injection" do
    it "does not let a crafted email bypass authentication" do
      create(:user, email: "victim@example.com", password: "password123")

      post session_path, params: { email: "' OR '1'='1", password: "anything" }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to be_present
    end

    it "treats a crafted email as a literal, parameterized value with no match" do
      create(:user, email: "victim@example.com")

      expect(User.find_by(email: "' OR '1'='1")).to be_nil
    end
  end

  describe "reflected/stored XSS" do
    it "escapes a malicious full_name when rendering the profile page" do
      payload = "<script>alert('xss')</script>"
      user = create(:user, full_name: payload, password: "password123")
      sign_in_as(user)

      get profile_path

      expect(response.body).not_to include(payload)
      expect(response.body).to include(CGI.escapeHTML(payload))
    end

    it "escapes a malicious full_name when rendering the admin users list" do
      payload = "<img src=x onerror=alert(1)>"
      admin = create(:user, :admin, password: "password123")
      create(:user, full_name: payload)
      sign_in_as(admin)

      get admin_users_path

      expect(response.body).not_to include(payload)
      expect(response.body).to include(CGI.escapeHTML(payload))
    end
  end

  describe "CSRF protection" do
    around do |example|
      original = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true
      begin
        example.run
      ensure
        ActionController::Base.allow_forgery_protection = original
      end
    end

    it "rejects a state-changing request without a valid authenticity token" do
      expect {
        post registration_path, params: {
          user: {
            full_name: "Attacker",
            email: "attacker@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
