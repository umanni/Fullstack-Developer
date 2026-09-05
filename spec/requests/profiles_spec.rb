require "rails_helper"

RSpec.describe "Profiles", type: :request do
  describe "GET /profile" do
    it "redirects unauthenticated visitors to sign in" do
      get profile_path

      expect(response).to redirect_to(new_session_path)
    end

    it "shows the signed in user's own info" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      get profile_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.full_name)
    end
  end

  describe "GET /profile/edit" do
    it "is accessible to the signed in user" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      get edit_profile_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /profile" do
    it "updates the signed in user's own info" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      patch profile_path, params: { user: { full_name: "New Name" } }

      expect(response).to redirect_to(profile_url)
      expect(user.reload.full_name).to eq("New Name")
    end

    it "keeps the current password when the password field is left blank" do
      user = create(:user, password: "original-password")
      sign_in_as(user, password: "original-password")

      patch profile_path, params: { user: { full_name: "New Name", password: "", password_confirmation: "" } }

      user.reload
      expect(user.full_name).to eq("New Name")
      expect(user.authenticate("original-password")).to eq(user)
    end

    it "ignores an injected role param and never promotes the user to admin" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      patch profile_path, params: { user: { full_name: "New Name", role: "admin" } }

      expect(user.reload).to be_no_admin
    end

    it "enqueues an avatar download job when an avatar_url is given" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      expect {
        patch profile_path, params: { user: { avatar_url: "https://example.com/avatar.png" } }
      }.to have_enqueued_job(AvatarDownloadJob).with(user.id, "https://example.com/avatar.png")
    end

    it "re-renders the form with errors when invalid" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      patch profile_path, params: { user: { email: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /profile" do
    it "deletes the signed in user's own account and signs them out" do
      user = create(:user, password: "password123")
      sign_in_as(user)

      expect { delete profile_path }.to change(User, :count).by(-1)
      expect(response).to redirect_to(new_session_path)

      get profile_path
      expect(response).to redirect_to(new_session_path)
    end
  end
end
