require "rails_helper"

RSpec.describe "Profiles" do
  let(:user) { create(:user, full_name: "Maria Silva") }

  describe "GET /profile" do
    it "shows the signed in user their own profile" do
      sign_in user

      get profile_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Maria Silva")
    end

    it "sends a visitor to the sign in page" do
      get profile_path

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "PATCH /profile" do
    it "updates the signed in user" do
      sign_in user

      patch profile_path, params: { user: { full_name: "Maria Silva Santos" } }

      expect(response).to redirect_to(profile_path)
      expect(user.reload.full_name).to eq("Maria Silva Santos")
    end

    it "never lets a user promote themselves" do
      sign_in user

      patch profile_path, params: { user: { full_name: "Maria", role: "admin" } }

      expect(user.reload).to be_user
    end

    it "rejects an invalid change" do
      sign_in user

      patch profile_path, params: { user: { email_address: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.email_address).to be_present
    end
  end

  describe "DELETE /profile" do
    it "deletes the signed in user's own account" do
      sign_in user

      expect { delete profile_path }.to change(User, :count).by(-1)

      expect(response).to redirect_to(new_session_path)
    end
  end
end
