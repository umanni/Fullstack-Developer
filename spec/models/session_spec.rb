require "rails_helper"

RSpec.describe Session, type: :model do
  it "has a valid factory" do
    expect(build(:session)).to be_valid
  end

  it { is_expected.to belong_to(:user) }

  it "requires a user" do
    session = build(:session, user: nil)

    expect(session).to be_invalid
    expect(session.errors[:user]).to include(/must exist/)
  end

  it "records the originating request metadata" do
    session = create(:session, ip_address: "203.0.113.7", user_agent: "Mozilla/5.0")

    expect(session.ip_address).to eq("203.0.113.7")
    expect(session.user_agent).to eq("Mozilla/5.0")
  end

  it "is removed together with its user" do
    session = create(:session)

    expect { session.user.destroy }.to change(described_class, :count).by(-1)
  end
end
