require "rails_helper"

RSpec.describe PasswordsMailer, type: :mailer do
  let(:user) { create(:user, email_address: "ada@example.com") }
  let(:mail) { described_class.reset(user) }

  it "addresses the reset to the user" do
    expect(mail.to).to eq([ "ada@example.com" ])
    expect(mail.subject).to eq("Reset your password")
    expect(mail.from).to eq([ "from@example.com" ])
  end

  it "renders both a html and a text part" do
    expect(mail.body.parts.map(&:content_type)).to include(
      a_string_starting_with("text/html"),
      a_string_starting_with("text/plain")
    )
  end

  it "includes a password reset link" do
    body = mail.body.encoded

    expect(body).to include("/passwords/")
    expect(body).to include('edit')
  end

  it "delivers" do
    expect { described_class.reset(user).deliver_now }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
