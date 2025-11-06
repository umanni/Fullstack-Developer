require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user) }

  context "when not logged in" do
    it "redirects to the login page" do
      get profile_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when logged in" do
    before do
      sign_in user
    end

    it "can see their own profile" do
      get profile_path
      expect(response).to be_successful
      expect(response.body).to include(user.full_name)
    end

    it "can update their profile without a password" do
      patch profile_path, params: {
        user: { full_name: "New Name", email: user.email }
      }
      expect(response).to redirect_to(profile_path)
      expect(user.reload.full_name).to eq("New Name")
    end
  end
end
