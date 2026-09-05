require "rails_helper"

RSpec.describe "Passwords", type: :request do
  describe "GET /passwords/new" do
    it "is accessible to a visitor" do
      get new_password_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /passwords" do
    it "sends a reset e-mail when the address exists" do
      user = create(:user)

      expect {
        post passwords_path, params: { email: user.email }
      }.to have_enqueued_mail(PasswordsMailer, :reset)

      expect(response).to redirect_to(new_session_path)
    end

    it "does not reveal whether the e-mail exists" do
      expect {
        post passwords_path, params: { email: "nobody@example.com" }
      }.not_to have_enqueued_mail(PasswordsMailer, :reset)

      expect(response).to redirect_to(new_session_path)
      follow_redirect!
      expect(response.body).to include("Instruções de redefinição enviadas (caso o e-mail exista).")
    end
  end

  describe "GET /passwords/:token/edit" do
    it "is accessible with a valid token" do
      user = create(:user)

      get edit_password_path(user.password_reset_token)

      expect(response).to have_http_status(:ok)
    end

    it "redirects with an alert when the token is invalid or expired" do
      get edit_password_path("bogus-token")

      expect(response).to redirect_to(new_password_path)
      follow_redirect!
      expect(response.body).to include("O link de redefinição é inválido ou expirou.")
    end
  end

  describe "PATCH /passwords/:token" do
    it "updates the password and signs the user out of every session" do
      user = create(:user, password: "old-password123")
      sign_in_as(user, password: "old-password123")
      token = user.password_reset_token

      patch password_path(token), params: { user: { password: "new-password123", password_confirmation: "new-password123" } }

      expect(response).to redirect_to(new_session_path)
      expect(user.reload.authenticate("new-password123")).to eq(user)
      expect(user.sessions.count).to eq(0)
    end

    it "redirects back to edit with an alert when the confirmation does not match" do
      user = create(:user)
      token = user.password_reset_token

      patch password_path(token), params: { user: { password: "new-password123", password_confirmation: "mismatch" } }

      expect(response).to redirect_to(edit_password_path(token))
      expect(user.reload.authenticate("new-password123")).to be false
    end
  end
end
