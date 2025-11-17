require 'rails_helper'

RSpec.describe "UsersController", type: :request do
  let(:admin)      { create(:user, :admin) }
  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }

  describe "GET /users/:id" do
    context "when signed in as the user" do
      it "returns http success" do
        sign_in user
        get user_path(user)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as an admin" do
      it "returns success" do
        sign_in admin
        get user_path(user)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as another regular user" do
      it "redirects with Access denied" do
        sign_in other_user
        get user_path(user)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied.")
      end
    end
  end
end
