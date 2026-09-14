require "rails_helper"

RSpec.describe "Passwords", type: :request do
  let!(:user) { create(:user, email_address: "ada@example.com", password: "password") }

  describe "GET /passwords/new" do
    it "is reachable without authentication" do
      get new_password_url

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /passwords" do
    it "sends reset instructions to a known address" do
      expect {
        post passwords_url, params: { email_address: "ada@example.com" }
      }.to have_enqueued_mail(PasswordsMailer, :reset)

      expect(response).to redirect_to(new_session_url)
      expect(flash[:notice]).to include('Password reset instructions sent')
    end

    it "finds the user even when the address needs normalizing" do
      expect {
        post passwords_url, params: { email_address: "  ADA@Example.COM " }
      }.to have_enqueued_mail(PasswordsMailer, :reset)
    end

    it "sends nothing for an unknown address" do
      expect {
        post passwords_url, params: { email_address: "nobody@example.com" }
      }.not_to have_enqueued_mail(PasswordsMailer, :reset)
    end

    it "gives an identical response for unknown addresses, so accounts cannot be enumerated" do
      post passwords_url, params: { email_address: "nobody@example.com" }
      unknown_flash = flash[:notice]

      post passwords_url, params: { email_address: "ada@example.com" }

      expect(unknown_flash).to eq(flash[:notice])
      expect(response).to redirect_to(new_session_url)
    end
  end

  describe "GET /passwords/:token/edit" do
    it "accepts a freshly generated token" do
      get edit_password_url(user.password_reset_token)

      expect(response).to have_http_status(:ok)
    end

    it "rejects a malformed token" do
      get edit_password_url("not-a-real-token")

      expect(response).to redirect_to(new_password_url)
      expect(flash[:alert]).to include('invalid or has expired')
    end
  end

  describe "PATCH /passwords/:token" do
    it "changes the password when the confirmation matches" do
      patch password_url(user.password_reset_token),
            params: { password: "new-password", password_confirmation: "new-password" }

      expect(response).to redirect_to(new_session_url)
      expect(flash[:notice]).to include('Password has been reset')
      expect(user.reload.authenticate("new-password")).to be_truthy
    end

    it "signs out every existing session after a successful reset" do
      create(:session, user: user)
      create(:session, user: user)

      expect {
        patch password_url(user.password_reset_token),
              params: { password: "new-password", password_confirmation: "new-password" }
      }.to change { user.sessions.count }.from(2).to(0)
    end

    it "refuses a mismatched confirmation and leaves the password alone" do
      # `password_reset_token` mints a new token (with a fresh expiry) on every
      # call, so hold on to the one we actually submit.
      token = user.password_reset_token

      patch password_url(token), params: { password: "new-password", password_confirmation: "different" }

      expect(response).to redirect_to(edit_password_url(token))
      expect(flash[:alert]).to include('Passwords did not match')
      expect(user.reload.authenticate("password")).to be_truthy
    end

    it "rejects a malformed token" do
      patch password_url("not-a-real-token"),
            params: { password: "new-password", password_confirmation: "new-password" }

      expect(response).to redirect_to(new_password_url)
      expect(user.reload.authenticate("password")).to be_truthy
    end
  end
end
