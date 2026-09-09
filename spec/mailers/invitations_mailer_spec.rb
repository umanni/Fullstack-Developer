require "rails_helper"

RSpec.describe InvitationsMailer do
  it "tells the person their account exists and how to claim it" do
    user = create(:user, full_name: "Maria Silva", email_address: "maria@example.com")

    mail = described_class.invite(user)

    expect(mail.to).to eq(["maria@example.com"])
    expect(mail.subject).to eq(I18n.t("invitations_mailer.invite.subject"))
    expect(mail.body.encoded).to include("Maria Silva", "maria@example.com")
  end

  it "carries a link that opens the password screen" do
    user = create(:user)

    mail = described_class.invite(user)
    token = mail.body.encoded[%r{/passwords/([^/\s"]+)/edit}, 1]

    expect(token).to be_present
    expect(User.find_by_token_for(:invitation, CGI.unescape(token))).to eq(user)
  end

  it "is written in the language the person chose" do
    user = create(:user, locale: "pt-BR")

    mail = described_class.invite(user)

    expect(mail.subject).to eq(I18n.t("invitations_mailer.invite.subject", locale: "pt-BR"))
    expect(I18n.locale).to eq(:en)
  end
end
