require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "#user_initials" do
    it "takes the first letter of the first and last words" do
      expect(helper.user_initials(build(:user, full_name: "Maria da Silva Santos"))).to eq("MS")
    end

    it "uses a single letter for a one-word name" do
      expect(helper.user_initials(build(:user, full_name: "Prince"))).to eq("P")
    end

    it "falls back to a placeholder when there is no name" do
      expect(helper.user_initials(build(:user, full_name: ""))).to eq("?")
    end
  end

  describe "#avatar_tag" do
    def upload
      Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/avatar.png"), "image/png")
    end

    it "renders the uploaded image when there is one" do
      user = create(:user)
      user.avatar.attach(upload)

      expect(helper.avatar_tag(user, size: 40)).to include("<img")
    end

    it "renders the remote image without leaking the referrer" do
      user = create(:user, avatar_url: "https://example.com/maria.png")

      markup = helper.avatar_tag(user, size: 40)

      expect(markup).to include('src="https://example.com/maria.png"')
      expect(markup).to include('referrerpolicy="no-referrer"')
    end

    it "renders initials when there is neither" do
      user = create(:user, full_name: "Maria Silva")

      markup = helper.avatar_tag(user, size: 40)

      expect(markup).to include("MS")
      expect(markup).not_to include("<img")
    end

    it "hides the initials from assistive technology, since the name is next to it" do
      expect(helper.avatar_tag(create(:user), size: 40)).to include('aria-hidden="true"')
    end
  end

  describe "#role_badge" do
    it "labels an administrator" do
      expect(helper.role_badge(build(:user, :admin))).to include(I18n.t("roles.admin"))
    end

    it "labels a regular user" do
      expect(helper.role_badge(build(:user))).to include(I18n.t("roles.user"))
    end
  end
end
