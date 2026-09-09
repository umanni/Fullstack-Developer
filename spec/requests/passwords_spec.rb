require "rails_helper"

RSpec.describe "Password resets" do
  let(:user) { create(:user, email_address: "maria@example.com") }

  describe "POST /passwords" do
    it "emails a reset link to an account that exists", :perform_enqueued do
      user

      expect { post passwords_path, params: { email_address: user.email_address } }
        .to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(ActionMailer::Base.deliveries.last.to).to eq([user.email_address])
    end

    it "sends nothing for an address with no account", :perform_enqueued do
      expect { post passwords_path, params: { email_address: "nobody@example.com" } }
        .not_to(change { ActionMailer::Base.deliveries.size })
    end

    # Answering differently would turn this form into a way of asking whether
    # somebody has an account here.
    it "answers identically either way" do
      user
      post passwords_path, params: { email_address: user.email_address }
      known = [response.status, response.location, flash[:notice]]

      post passwords_path, params: { email_address: "nobody@example.com" }
      unknown = [response.status, response.location, flash[:notice]]

      expect(unknown).to eq(known)
    end
  end

  describe "PATCH /passwords/:token" do
    let(:token) { user.password_reset_token }

    it "changes the password" do
      patch password_path(token), params: {
        password: "a-brand-new-password", password_confirmation: "a-brand-new-password"
      }

      expect(user.reload.authenticate("a-brand-new-password")).to eq(user)
    end

    it "signs every existing session out" do
      user.sessions.create!(user_agent: "rspec", ip_address: "127.0.0.1")

      expect do
        patch password_path(token), params: {
          password: "a-brand-new-password", password_confirmation: "a-brand-new-password"
        }
      end.to change { user.sessions.count }.to(0)
    end

    it "refuses a mismatched confirmation" do
      patch password_path(token), params: {
        password: "a-brand-new-password", password_confirmation: "something else"
      }

      expect(user.reload.authenticate("a-brand-new-password")).to be(false)
    end

    it "refuses a token that was never valid" do
      patch password_path("not-a-real-token"), params: {
        password: "a-brand-new-password", password_confirmation: "a-brand-new-password"
      }

      expect(response).to redirect_to(new_password_path)
      expect(user.reload.authenticate("a-brand-new-password")).to be(false)
    end
  end

  # An invited person arrives at the same screen through a different token.
  describe "the invitation link" do
    let(:invitation) { user.generate_token_for(:invitation) }

    it "opens the password screen, worded as a welcome" do
      get edit_password_path(invitation)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("passwords.edit.invited_title"))
    end

    it "sets the first password" do
      patch password_path(invitation), params: {
        password: "a-brand-new-password", password_confirmation: "a-brand-new-password"
      }

      expect(response).to redirect_to(new_session_path)
      expect(user.reload.authenticate("a-brand-new-password")).to eq(user)
    end

    it "stops working once a password has been set, since the salt has changed" do
      used = invitation
      patch password_path(used), params: {
        password: "a-brand-new-password", password_confirmation: "a-brand-new-password"
      }

      get edit_password_path(used)

      expect(response).to redirect_to(new_password_path)
    end

    it "expires" do
      token = invitation

      travel(User::INVITATION_VALID_FOR + 1.day) do
        get edit_password_path(token)

        expect(response).to redirect_to(new_password_path)
      end
    end
  end
end
