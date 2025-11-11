require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  before do
    sign_in admin_user, scope: :user
  end

  describe "GET /admin/users" do
    it "returns http success" do
      get admin_users_path
      expect(response).to have_http_status(:success)
    end

    it "displays users list" do
      create(:user, full_name: "Test User")
      get admin_users_path
      expect(response.body).to include("Test User")
    end
  end

  describe "GET /admin/users/:id" do
    it "returns http success" do
      user = create(:user)
      get admin_user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/users/new" do
    it "returns http success" do
      get new_admin_user_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/users" do
    let(:valid_params) do
      {
        user: {
          full_name: "New User",
          email: "new@example.com",
          role: "user",
          password: "123456",
          password_confirmation: "123456"
        }
      }
    end

    it "creates a new user" do
      expect {
        post admin_users_path, params: valid_params
      }.to change(User, :count).by(1)
    end

    it "redirects after creation" do
      post admin_users_path, params: valid_params
      expect(response).to redirect_to(admin_user_path(User.last))
    end
  end

  describe "GET /admin/users/:id/edit" do
    it "returns http success" do
      user = create(:user)
      get edit_admin_user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/users/:id" do
    let(:user) { create(:user, full_name: "Old Name") }

    it "updates user" do
      patch admin_user_path(user), params: { user: { full_name: "Updated Name" } }
      user.reload
      expect(user.full_name).to eq("Updated Name")
    end
  end

  describe "DELETE /admin/users/:id" do
    it "deletes a user" do
      user = create(:user)
      expect {
        delete admin_user_path(user)
      }.to change(User, :count).by(-1)
    end

    it "cannot delete own account" do
      expect {
        delete admin_user_path(admin_user)
      }.not_to change(User, :count)
    end
  end

  describe "PATCH /admin/users/:id/toggle_role" do
    let(:user) { create(:user, role: "user") }

    it "toggles user role to admin" do
      patch toggle_role_admin_user_path(user)
      user.reload
      expect(user.role).to eq("admin")
    end

    it "does not allow admin to remove own admin role" do
      patch toggle_role_admin_user_path(admin_user)
      admin_user.reload
      expect(admin_user.role).to eq("admin")
    end
  end

  context "when not signed in as admin" do
    before do
      sign_out admin_user
      sign_in regular_user
    end
  end
end
