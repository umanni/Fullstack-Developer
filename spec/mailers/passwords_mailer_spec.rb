require "rails_helper"

RSpec.describe PasswordsMailer, type: :mailer do
  let(:user) { create(:user) }

  def token_from(mail)
    mail.text_part.body.to_s[%r{/passwords/([^/]+)/edit}, 1]
  end

  describe "#reset" do
    let(:mail) { described_class.reset(user) }

    it "renders in Portuguese, addressed to the user, with a valid reset link" do
      expect(mail.subject).to eq("Redefinição de senha")
      expect(mail.to).to eq([ user.email ])
      expect(mail.text_part.body.to_s).to include("redefinir sua senha")
      expect(User.find_by_password_reset_token!(token_from(mail))).to eq(user)
    end
  end

  describe "#welcome" do
    let(:mail) { described_class.welcome(user) }

    it "renders in Portuguese, addressed to the user, with a valid set-password link" do
      expect(mail.subject).to eq("Defina sua senha")
      expect(mail.to).to eq([ user.email ])
      expect(mail.text_part.body.to_s).to include("Defina sua senha")
      expect(User.find_by_password_reset_token!(token_from(mail))).to eq(user)
    end
  end
end
