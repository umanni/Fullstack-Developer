require "rails_helper"

RSpec.describe AuditEvent do
  describe ".record!" do
    it "copies both addresses, so the trail reads after an account is gone" do
      actor = create(:user, :admin, email_address: "ada@example.com")
      subject_user = create(:user, full_name: "Maria Silva", email_address: "maria@example.com")

      event = described_class.record!(action: :deleted, actor: actor, subject: subject_user)
      subject_user.destroy!

      expect(event.reload.subject).to be_nil
      expect(event.subject_name).to eq("maria@example.com")
      expect(event.actor_name).to eq(actor.full_name)
    end

    it "attributes an action with nobody behind it to the system" do
      event = described_class.record!(action: :created, actor: nil, subject: create(:user))

      expect(event.actor_email).to eq(described_class::SYSTEM)
    end

    it "takes an address for an actor who no longer exists" do
      event = described_class.record!(action: :imported, actor: nil, actor_email: "grace@example.com",
                                      subject: create(:user))

      expect(event.actor_name).to eq("grace@example.com")
    end
  end

  describe ".changes_worth_recording" do
    it "reports the columns that changed and never the password digest" do
      user = create(:user, full_name: "Maria Silva")

      user.update!(full_name: "Maria Silva Santos", password: "another-long-password")

      expect(described_class.changes_worth_recording(user).keys).to eq(["full_name"])
    end
  end

  it "keeps the newest event first" do
    older = create(:audit_event, created_at: 2.days.ago)
    newer = create(:audit_event, created_at: 1.hour.ago)

    expect(described_class.recent_first.to_a).to eq([newer, older])
  end
end
