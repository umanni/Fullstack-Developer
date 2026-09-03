require "rails_helper"

RSpec.describe User do
  def upload(name, content_type: "image/png")
    Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/#{name}"), content_type)
  end

  describe "uploads" do
    it "accepts a genuine PNG" do
      user = build(:user)
      user.avatar.attach(upload("avatar.png"))

      expect(user).to be_valid
    end

    # The limit is lowered rather than the fixture enlarged: a three megabyte
    # PNG committed to exercise one comparison would outweigh the rest of the
    # repository put together.
    it "rejects a file larger than the limit" do
      stub_const("User::MAX_AVATAR_BYTES", 32)
      user = build(:user)
      user.avatar.attach(upload("avatar.png"))

      expect(user).not_to be_valid
      expect(user.errors[:avatar]).to be_present
    end

    # The declared content type comes from the client and can say anything. What
    # matters is what the bytes actually are.
    it "rejects a shell script dressed up as a PNG" do
      user = build(:user)
      user.avatar.attach(upload("not-really-an-image.png", content_type: "image/png"))

      expect(user).not_to be_valid
      expect(user.errors[:avatar]).to be_present
    end
  end

  describe "remote avatar_url" do
    it "accepts an https URL" do
      expect(build(:user, avatar_url: "https://example.com/maria.png")).to be_valid
    end

    it "accepts a plain http URL" do
      expect(build(:user, avatar_url: "http://example.com/maria.png")).to be_valid
    end

    it "accepts a blank value" do
      expect(build(:user, avatar_url: "")).to be_valid
    end

    it "rejects a javascript: URL" do
      expect(build(:user, avatar_url: "javascript:alert(1)")).not_to be_valid
    end

    it "rejects a data: URL" do
      expect(build(:user, avatar_url: "data:text/html;base64,PHNjcmlwdD4=")).not_to be_valid
    end

    it "rejects a file: URL" do
      expect(build(:user, avatar_url: "file:///etc/passwd")).not_to be_valid
    end

    it "rejects something that is not a URL at all" do
      expect(build(:user, avatar_url: "not a url")).not_to be_valid
    end
  end

  describe "which avatar is shown" do
    it "prefers an uploaded file over a remote URL" do
      user = create(:user, avatar_url: "https://example.com/maria.png")
      user.avatar.attach(upload("avatar.png"))

      expect(user.avatar_source).to eq(:attachment)
    end

    it "falls back to the remote URL when nothing was uploaded" do
      user = create(:user, avatar_url: "https://example.com/maria.png")

      expect(user.avatar_source).to eq(:remote)
    end

    it "falls back to initials when there is neither" do
      expect(create(:user).avatar_source).to eq(:initials)
    end
  end
end
