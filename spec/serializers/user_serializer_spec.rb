require "rails_helper"

RSpec.describe UserSerializer do
  describe "#as_json" do
    it "exposes the public attributes" do
      user = create(:user, full_name: "Ada Lovelace", email_address: "ada@example.com")

      expect(described_class.new(user).as_json).to include(
        id: user.id,
        full_name: "Ada Lovelace",
        email_address: "ada@example.com",
        role: "member",
        admin: false
      )
    end

    it "flags an admin" do
      expect(described_class.new(create(:user, :admin)).as_json)
        .to include(role: "admin", admin: true)
    end

    it "formats created_at as iso8601" do
      user = create(:user)

      expect(described_class.new(user).as_json[:created_at]).to eq(user.created_at.iso8601)
    end

    it "never leaks the password digest" do
      json = described_class.new(create(:user)).as_json

      expect(json).not_to include(:password_digest)
      expect(json.values.join).not_to include("password")
    end
  end

  describe "avatar_url" do
    it "falls back to the remote avatar_url when no image is attached" do
      user = create(:user, :with_avatar_url)

      expect(described_class.new(user).as_json[:avatar_url])
        .to eq("https://cdn.example.com/avatars/ada.png")
    end

    it "is nil when there is neither an attachment nor a url" do
      expect(described_class.new(create(:user)).as_json[:avatar_url]).to be_nil
    end

    it "is nil when avatar_url is blank rather than an empty string" do
      expect(described_class.new(create(:user, avatar_url: "")).as_json[:avatar_url]).to be_nil
    end

    it "prefers the attached image, served as a variant path" do
      user = create(:user, :with_avatar_image, avatar_url: "https://cdn.example.com/ignored.png")

      url = described_class.new(user).as_json[:avatar_url]

      expect(url).to start_with("/rails/active_storage/representations/")
      expect(url).not_to include("cdn.example.com")
    end

    it "returns a path, not a host-qualified url" do
      user = create(:user, :with_avatar_image)

      expect(described_class.new(user).as_json[:avatar_url]).not_to match(%r{\Ahttps?://})
    end
  end

  describe ".collection" do
    it "serializes each user" do
      create(:user, full_name: "Ada Lovelace")
      create(:user, full_name: "Grace Hopper")

      expect(described_class.collection(User.order(:full_name)).pluck(:full_name))
        .to eq([ "Ada Lovelace", "Grace Hopper" ])
    end

    it "returns an empty array for no users" do
      expect(described_class.collection(User.none)).to eq([])
    end
  end

  describe "remote_avatar_url" do
    it "is the stored remote URL even when an uploaded image is what gets displayed" do
      user = create(:user, :with_avatar_image, avatar_url: "https://cdn.example.com/kept.png")

      expect(described_class.new(user).as_json[:remote_avatar_url]).to eq("https://cdn.example.com/kept.png")
    end

    it "is nil when only an image was uploaded, so the form never posts a storage path back" do
      expect(described_class.new(create(:user, :with_avatar_image)).as_json[:remote_avatar_url]).to be_nil
    end
  end
end
