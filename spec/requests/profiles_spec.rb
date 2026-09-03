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

  describe "the avatar" do
    def upload(name, content_type: "image/png")
      Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/#{name}"), content_type)
    end

    it "accepts an uploaded image" do
      sign_in user

      patch profile_path, params: { user: { avatar: upload("avatar.png") } }

      expect(user.reload.avatar).to be_attached
    end

    it "refuses a file that is not really an image" do
      sign_in user

      patch profile_path, params: { user: { avatar: upload("not-really-an-image.png") } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.avatar).not_to be_attached
    end

    it "removes the uploaded image when asked" do
      user.avatar.attach(upload("avatar.png"))
      sign_in user

      patch profile_path, params: { user: { remove_avatar: "1" } }

      expect(user.reload.avatar).not_to be_attached
    end

    it "keeps the uploaded image when not asked to remove it" do
      user.avatar.attach(upload("avatar.png"))
      sign_in user

      patch profile_path, params: { user: { full_name: "Maria Silva Santos" } }

      expect(user.reload.avatar).to be_attached
    end

    it "refuses a remote URL that is not an ordinary web link" do
      sign_in user

      patch profile_path, params: { user: { avatar_url: "javascript:alert(1)" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.avatar_url).to be_nil
      # The form legitimately echoes the rejected value back into the input, where
      # it is inert. What must never happen is it becoming an image source.
      expect(response.body).not_to include('src="javascript:')
      expect(response.body).not_to include('src="data:')
    end
  end
end
