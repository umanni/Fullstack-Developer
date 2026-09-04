require "rails_helper"

RSpec.describe "Admin activity" do
  let(:administrator) { create(:user, :admin, full_name: "Ada Lovelace") }

  describe "GET /admin/activity" do
    before { sign_in administrator }

    it "lists what administrators did, newest first" do
      create(:audit_event, actor: administrator, subject: create(:user, full_name: "Maria Silva"),
                           action: :promoted, created_at: 1.hour.ago)
      create(:audit_event, actor: administrator, subject: create(:user, full_name: "Joao Souza"),
                           action: :deleted, created_at: 2.days.ago)

      get admin_audit_events_path

      expect(response).to have_http_status(:ok)
      expect(response.body.index("Maria Silva")).to be < response.body.index("Joao Souza")
      expect(response.body).to include(I18n.t("admin.audit_events.actions.promoted"))
    end

    it "says so when nothing has happened" do
      get admin_audit_events_path

      expect(response.body).to include(I18n.t("admin.audit_events.index.empty_title"))
    end
  end

  it "keeps a regular user out" do
    sign_in create(:user)

    get admin_audit_events_path

    expect(response).to redirect_to(profile_path)
  end

  # The trail is written from the actions themselves, so these read like the
  # administration screens rather than like the model.
  describe "what gets recorded" do
    before { sign_in administrator }

    it "records the creation of an account, and who did it" do
      expect do
        post admin_users_path, params: {
          user: { full_name: "Maria Silva", email_address: "maria@example.com",
                  password: "a-sufficiently-long-password" }
        }
      end.to change(AuditEvent, :count).by(1)

      expect(AuditEvent.last).to have_attributes(
        action: "created", actor: administrator, subject_email: "maria@example.com"
      )
    end

    it "tells a promotion from an ordinary change" do
      user = create(:user)

      patch admin_user_path(user), params: { user: { role: "admin" } }

      expect(AuditEvent.last.action).to eq("promoted")
    end

    it "tells a demotion from an ordinary change" do
      create(:user, :admin)
      colleague = create(:user, :admin)

      patch admin_user_path(colleague), params: { user: { role: "user" } }

      expect(AuditEvent.last.action).to eq("demoted")
    end

    it "records which columns an ordinary change touched" do
      user = create(:user, full_name: "Maria Silva")

      patch admin_user_path(user), params: { user: { full_name: "Maria Silva Santos" } }

      expect(AuditEvent.last).to have_attributes(action: "updated")
      expect(AuditEvent.last.details.keys).to include("full_name")
    end

    it "records a deletion, and survives the account it refers to" do
      user = create(:user, email_address: "maria@example.com")

      delete admin_user_path(user)

      expect(AuditEvent.last).to have_attributes(action: "deleted", subject: nil,
                                                 subject_email: "maria@example.com")
    end

    it "writes nothing when the change was refused" do
      user = create(:user)

      expect do
        patch admin_user_path(user), params: { user: { email_address: "not an address" } }
      end.not_to change(AuditEvent, :count)
    end
  end
end
