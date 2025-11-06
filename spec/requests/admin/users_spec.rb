require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  context "as a regular user" do
    before do
      sign_in user, scope: :user
    end

    it "is redirected when trying to access the user list" do
      get admin_users_path
      # Use the new root path helper from your routes file
      expect(response).to redirect_to(profile_path)
      expect(flash[:alert]).to eq("You must be an admin to access this section.")
    end
  end

  context "as an admin" do
    before do
      sign_in admin, scope: :user
    end

    let!(:user_to_toggle) { create(:user) }

    it "can access the user list" do
      get admin_users_path
      expect(response).to be_successful
    end

    it "can create a new user" do
      user_attributes = attributes_for(:user, full_name: "Created by Admin")

      expect {
        post admin_users_path, params: { user: user_attributes }
      }.to change(User, :count).by(1)

      expect(User.last.full_name).to eq("Created by Admin")
    end

    let!(:user_to_toggle) { create(:user) }
    it "can toggle a user's role" do
      # Create the user we are going to toggle
      expect(user_to_toggle.admin?).to be(false)

      # Use the specific user in the path
      patch admin_toggle_user_role_path(user_to_toggle)

      expect(user_to_toggle.reload.admin?).to be(true)
    end
  end
end
