require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  let(:admin) { create(:user, :admin, password: "password123") }

  describe "GET /admin/users" do
    it "redirects unauthenticated visitors to sign in" do
      get admin_users_path

      expect(response).to redirect_to(new_session_path)
    end

    it "redirects a no_admin user to their profile" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      get admin_users_path

      expect(response).to redirect_to(profile_url)
    end

    it "lists every user for an admin" do
      other_user = create(:user)
      sign_in_as(admin)

      get admin_users_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(admin.full_name)
      expect(response.body).to include(other_user.full_name)
    end
  end

  describe "GET /admin/users/new" do
    it "is forbidden for a no_admin user" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      get new_admin_user_path

      expect(response).to redirect_to(profile_url)
    end

    it "is accessible to an admin" do
      sign_in_as(admin)

      get new_admin_user_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/users" do
    it "allows an admin to create a user with any role" do
      sign_in_as(admin)

      expect {
        post admin_users_path, params: {
          user: {
            full_name: "New Admin",
            email: "new-admin@example.com",
            password: "password123",
            password_confirmation: "password123",
            role: "admin"
          }
        }
      }.to change(User, :count).by(1)

      expect(User.find_by(email: "new-admin@example.com")).to be_admin
      expect(response).to redirect_to(admin_users_url)
    end

    it "enqueues an avatar download job when an avatar_url is given" do
      sign_in_as(admin)

      expect {
        post admin_users_path, params: {
          user: {
            full_name: "New User",
            email: "new-user@example.com",
            password: "password123",
            password_confirmation: "password123",
            role: "no_admin",
            avatar_url: "https://example.com/avatar.png"
          }
        }
      }.to have_enqueued_job(AvatarDownloadJob)
    end

    it "is forbidden for a no_admin user" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      expect {
        post admin_users_path, params: {
          user: { full_name: "X", email: "x@example.com", password: "password123", password_confirmation: "password123" }
        }
      }.not_to change(User, :count)

      expect(response).to redirect_to(profile_url)
    end

    it "re-renders the form with errors when invalid" do
      sign_in_as(admin)

      expect {
        post admin_users_path, params: { user: { full_name: "", email: "", password: "", password_confirmation: "" } }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /admin/users/:id" do
    it "allows an admin to update another user, including their role" do
      other_user = create(:user)
      sign_in_as(admin)

      patch admin_user_path(other_user), params: { user: { full_name: "Updated Name", role: "admin" } }

      expect(response).to redirect_to(admin_users_url)
      expect(other_user.reload.full_name).to eq("Updated Name")
      expect(other_user).to be_admin
    end

    it "keeps the current password when the password field is left blank" do
      other_user = create(:user, password: "original-password")
      sign_in_as(admin)

      patch admin_user_path(other_user), params: { user: { full_name: "Updated Name", password: "", password_confirmation: "" } }

      other_user.reload
      expect(other_user.full_name).to eq("Updated Name")
      expect(other_user.authenticate("original-password")).to eq(other_user)
    end

    it "is forbidden for a no_admin user" do
      other_user = create(:user)
      user = create(:user, password: "password123")
      sign_in_as(user)

      patch admin_user_path(other_user), params: { user: { full_name: "Hacked" } }

      expect(response).to redirect_to(profile_url)
      expect(other_user.reload.full_name).not_to eq("Hacked")
    end

    it "re-renders the form with errors when invalid" do
      other_user = create(:user)
      sign_in_as(admin)

      patch admin_user_path(other_user), params: { user: { full_name: "", email: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /admin/users/:id" do
    it "allows an admin to delete another user" do
      other_user = create(:user)
      sign_in_as(admin)

      expect { delete admin_user_path(other_user) }.to change(User, :count).by(-1)
      expect(response).to redirect_to(admin_users_url)
    end
  end

  describe "PATCH /admin/users/:id/toggle_role" do
    it "toggles another user's role" do
      other_user = create(:user)
      sign_in_as(admin)

      patch toggle_role_admin_user_path(other_user)

      expect(other_user.reload).to be_admin
      expect(response).to redirect_to(admin_users_url)
    end

    it "refuses to let an admin change their own role" do
      sign_in_as(admin)

      patch toggle_role_admin_user_path(admin)

      expect(admin.reload).to be_admin
      expect(response).to redirect_to(admin_users_url)
      expect(flash[:alert]).to be_present
    end

    it "is forbidden for a no_admin user" do
      other_user = create(:user)
      user = create(:user, password: "password123")
      sign_in_as(user)

      patch toggle_role_admin_user_path(other_user)

      expect(other_user.reload).not_to be_admin
      expect(response).to redirect_to(profile_url)
    end
  end
end
