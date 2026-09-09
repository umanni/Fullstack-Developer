require "rails_helper"

RSpec.describe "Sessions" do
  describe "POST /session" do
    it "sends an administrator to the admin dashboard" do
      sign_in create(:user, :admin)

      expect(response).to redirect_to(admin_dashboard_path)
    end

    it "sends a regular user to their own profile" do
      sign_in create(:user)

      expect(response).to redirect_to(profile_path)
    end

    it "refuses a wrong password" do
      user = create(:user)

      sign_in(user, password: "wrong password")

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to be_present
    end

    it "gives the same answer for an unknown email address" do
      post session_path, params: { email_address: "nobody@example.com", password: "whatever" }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to eq(I18n.t("sessions.invalid_credentials"))
    end
  end

  describe "DELETE /session" do
    it "signs the user out" do
      sign_in create(:user)

      delete session_path

      expect(response).to redirect_to(new_session_path)

      get profile_path
      expect(response).to redirect_to(new_session_path)
    end
  end
end
