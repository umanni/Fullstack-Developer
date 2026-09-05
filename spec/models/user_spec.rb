require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to have_secure_password }

    it "rejects a malformed email" do
      user = build(:user, email: "not-an-email")

      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "rejects a password shorter than 8 characters" do
      user = build(:user, password: "short1", password_confirmation: "short1")

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end

  describe "email normalization" do
    it "strips whitespace and downcases the email before saving" do
      user = create(:user, email: "  MixedCase@Example.com  ")

      expect(user.email).to eq("mixedcase@example.com")
    end
  end

  describe "role enum" do
    it "defaults to no_admin" do
      user = User.new

      expect(user.role).to eq("no_admin")
      expect(user).to be_no_admin
    end

    it { is_expected.to define_enum_for(:role).with_values(no_admin: 0, admin: 1) }
  end

  describe "associations" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
  end

  describe "avatar" do
    it "accepts a supported image within the size limit" do
      user = build(:user)
      user.avatar.attach(io: StringIO.new("bytes"), filename: "avatar.png", content_type: "image/png")

      expect(user).to be_valid
    end

    it "rejects an unsupported content type" do
      user = build(:user)
      user.avatar.attach(io: StringIO.new("not-an-image"), filename: "file.txt", content_type: "text/plain")

      expect(user).not_to be_valid
      expect(user.errors[:avatar]).to be_present
    end

    it "rejects a file that is too large" do
      stub_const("User::AVATAR_MAX_BYTES", 10)
      user = build(:user)
      user.avatar.attach(io: StringIO.new("x" * 20), filename: "avatar.png", content_type: "image/png")

      expect(user).not_to be_valid
      expect(user.errors[:avatar]).to be_present
    end
  end

  describe "avatar_url" do
    it "rejects a value that is not a valid http(s) URL" do
      user = build(:user, avatar_url: "not a url")

      expect(user).not_to be_valid
      expect(user.errors[:avatar_url]).to be_present
    end

    it "accepts a valid http(s) URL" do
      user = build(:user, avatar_url: "https://example.com/avatar.png")

      expect(user).to be_valid
    end

    it "enqueues a download job after a successful save" do
      user = build(:user, avatar_url: "https://example.com/avatar.png")

      expect { user.save! }.to have_enqueued_job(AvatarDownloadJob).with { |id, url|
        expect(id).to eq(user.id)
        expect(url).to eq("https://example.com/avatar.png")
      }
    end

    it "does not enqueue a download job when blank" do
      user = build(:user)

      expect { user.save! }.not_to have_enqueued_job(AvatarDownloadJob)
    end
  end

  describe "dashboard broadcasts" do
    include ActionCable::TestHelper

    it "broadcasts updated counts when a user is created" do
      expect { create(:user) }.to have_broadcasted_to("admin_dashboard")
    end

    it "broadcasts updated counts when a user is destroyed" do
      user = create(:user)

      expect { user.destroy }.to have_broadcasted_to("admin_dashboard")
    end

    it "broadcasts updated counts when a user's role changes" do
      user = create(:user)

      expect { user.update!(role: :admin) }.to have_broadcasted_to("admin_dashboard")
    end

    it "does not broadcast when an unrelated attribute changes" do
      user = create(:user)

      expect { user.update!(full_name: "New Name") }.not_to have_broadcasted_to("admin_dashboard")
    end

    it "does not broadcast when skip_dashboard_broadcast is set (bulk import path)" do
      user = build(:user, skip_dashboard_broadcast: true)

      expect { user.save! }.not_to have_broadcasted_to("admin_dashboard")
    end

    it "self.broadcast_dashboard_counts! broadcasts on demand" do
      expect { User.broadcast_dashboard_counts! }.to have_broadcasted_to("admin_dashboard")
    end
  end
end
