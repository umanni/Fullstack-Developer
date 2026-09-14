require "rails_helper"

RSpec.describe "Inertia shared data", type: :request do
  # `inertia.props` symbolizes only the top level, so nested props are compared
  # after a deep symbolize to keep the expectations readable.
  def props = inertia.props.deep_symbolize_keys

  let(:user) { create(:user, full_name: "Ada Lovelace", email_address: "ada@example.com") }

  describe "auth.user" do
    it "shares the signed-in user, serialized" do
      sign_in_as(user)

      get profile_path

      expect(props[:auth][:user]).to include(
        id: user.id, full_name: "Ada Lovelace", email_address: "ada@example.com",
        role: "member", admin: false
      )
    end

    it "flags an admin so the front end can gate admin-only UI" do
      sign_in_as(create(:user, :admin))

      get admin_dashboard_path

      expect(props[:auth][:user]).to include(role: "admin", admin: true)
    end

    it "never leaks the password digest" do
      sign_in_as(user)

      get profile_path

      expect(props[:auth][:user]).not_to include(:password_digest)
      expect(response.body).not_to include(user.password_digest)
    end
  end

  describe "flash" do
    it "shares an alert set by a redirect" do
      sign_in_as(user)

      get admin_dashboard_path # a member is turned away with an alert, to the root
      follow_redirect!         # which forwards them on to their profile
      follow_redirect!

      expect(props[:flash]).to eq(notice: nil, alert: "You are not authorized to do that.")
    end

    it "shares both keys, nil-valued, when nothing was flashed" do
      sign_in_as(user)

      get profile_path

      expect(props[:flash]).to eq(notice: nil, alert: nil)
    end
  end
end
