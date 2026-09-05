require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST /session" do
    it "signs in a no_admin user and redirects to the profile" do
      user = create(:user, password: "password123")

      sign_in_as(user)

      expect(response).to redirect_to(profile_url)
    end

    it "signs in an admin user and redirects to the admin dashboard" do
      admin = create(:user, :admin, password: "password123")

      sign_in_as(admin, password: "password123")

      expect(response).to redirect_to(admin_dashboard_url)
    end

    it "rejects invalid credentials" do
      user = create(:user, password: "password123")

      sign_in_as(user, password: "wrong-password")

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "DELETE /session" do
    it "signs the user out" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      delete session_path

      expect(response).to redirect_to(new_session_path)
      get profile_path
      expect(response).to redirect_to(new_session_path)
    end
  end
end
