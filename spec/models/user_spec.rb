require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  def raw_email_column(record)
    described_class.connection.select_value(
      described_class.sanitize_sql_array([ "SELECT email_address FROM users WHERE id = ?", record.id ])
    )
  end

  it "has a valid factory" do
    expect(user).to be_valid
  end

  describe "associations and attachments" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:imports).dependent(:destroy) }

    it "destroys dependent sessions when the user is destroyed" do
      user = create(:user)
      create(:session, user: user)

      expect { user.destroy }.to change(Session, :count).by(-1)
    end

    it "exposes an avatar_image attachment" do
      expect(build(:user, :with_avatar_image).avatar_image).to be_attached
    end
  end

  describe "full_name" do
    it { is_expected.to validate_presence_of(:full_name) }

    it "rejects a name shorter than 2 characters" do
      user.full_name = "A"
      expect(user).to be_invalid
      expect(user.errors[:full_name]).to include(/too short/)
    end

    it "rejects a name longer than 120 characters" do
      user.full_name = "a" * 121
      expect(user).to be_invalid
      expect(user.errors[:full_name]).to include(/too long/)
    end

    it "accepts a name at both ends of the allowed range" do
      expect(build(:user, full_name: "Ad")).to be_valid
      expect(build(:user, full_name: "a" * 120)).to be_valid
    end

    it "squishes surrounding and repeated whitespace" do
      user.full_name = "  Ada   Lovelace \n"
      expect(user.full_name).to eq("Ada Lovelace")
    end

    it "leaves nil alone (Rails skips normalization for nil unless apply_to_nil) and rejects it" do
      user.full_name = nil

      expect(user.full_name).to be_nil
      expect(user).to be_invalid
      expect(user.errors[:full_name]).to include(/can't be blank/)
    end

    it "normalizes an all-whitespace name to blank and rejects it" do
      user.full_name = "   \n  "

      expect(user.full_name).to eq("")
      expect(user).to be_invalid
    end
  end

  describe "email_address" do
    it "strips and downcases on assignment" do
      user.email_address = "  ADA@Example.COM  "
      expect(user.email_address).to eq("ada@example.com")
    end

    it "requires presence" do
      user.email_address = nil
      expect(user).to be_invalid
      expect(user.errors[:email_address]).to include(/can't be blank/)
    end

    it { is_expected.to allow_value("ada@example.com").for(:email_address) }
    it { is_expected.to allow_value("ada+tag@sub.example.co.uk").for(:email_address) }
    it { is_expected.not_to allow_value("not-an-email").for(:email_address) }
    it { is_expected.not_to allow_value("ada@").for(:email_address) }

    it "rejects a duplicate address" do
      create(:user, email_address: "ada@example.com")
      duplicate = build(:user, email_address: "ada@example.com")

      expect(duplicate).to be_invalid
      expect(duplicate.errors[:email_address]).to include(/has already been taken/)
    end

    it "treats addresses differing only by case or padding as duplicates" do
      create(:user, email_address: "ada@example.com")

      expect(build(:user, email_address: "  ADA@Example.COM ")).to be_invalid
    end

    describe "encryption" do
      let!(:persisted) { create(:user, email_address: "ada@example.com") }

      it "stores ciphertext rather than the plaintext address" do
        raw = raw_email_column(persisted)

        expect(raw).not_to include("ada@example.com")
        expect(raw).to include('"p"') # Active Record encryption envelope
      end

      it "decrypts transparently on read" do
        expect(described_class.find(persisted.id).email_address).to eq("ada@example.com")
      end

      it "is deterministic, so exact lookups still work" do
        expect(described_class.find_by(email_address: "ada@example.com")).to eq(persisted)
      end
    end
  end

  describe "role" do
    it "defaults to member" do
      expect(described_class.new.role).to eq("member")
      expect(described_class.new).to be_member
    end

    it { is_expected.to define_enum_for(:role).with_values(member: 0, admin: 1) }

    it "exposes enum scopes" do
      member = create(:user)
      admin  = create(:user, :admin)

      expect(described_class.member).to contain_exactly(member)
      expect(described_class.admin).to contain_exactly(admin)
    end

    it "rejects an unknown role through validation instead of raising" do
      expect { user.role = :wizard }.not_to raise_error
      expect(user).to be_invalid
      expect(user.errors[:role]).to include(/is not included in the list/)
    end
  end

  describe "password" do
    it "authenticates with the correct password" do
      create(:user, email_address: "ada@example.com", password: "secret123")

      authenticated = described_class.authenticate_by(
        email_address: "ada@example.com", password: "secret123"
      )
      expect(authenticated).to be_present
    end

    it "does not authenticate with a wrong password" do
      create(:user, email_address: "ada@example.com", password: "secret123")

      expect(
        described_class.authenticate_by(email_address: "ada@example.com", password: "nope")
      ).to be_nil
    end

    it "requires at least eight characters" do
      record = build(:user, password: "short", password_confirmation: "short")

      expect(record).not_to be_valid
      expect(record.errors[:password]).to include("is too short (minimum is 8 characters)")
    end

    it "accepts exactly eight characters" do
      expect(build(:user, password: "12345678", password_confirmation: "12345678")).to be_valid
    end

    it "does not re-validate the password on an update that leaves it alone" do
      record = create(:user, password: "secret123")

      expect(record.update(full_name: "Ada King")).to be(true)
    end

    it "stores a digest rather than the password" do
      record = create(:user, password: "secret123")

      expect(record.password_digest).to be_present
      expect(record.password_digest).not_to include("secret123")
    end
  end

  describe "avatar_url" do
    it { is_expected.to allow_value("https://cdn.example.com/a.png").for(:avatar_url) }
    it { is_expected.to allow_value("").for(:avatar_url) }
    it { is_expected.to allow_value(nil).for(:avatar_url) }
    it { is_expected.not_to allow_value("http://insecure.example.com/a.png").for(:avatar_url) }
    it { is_expected.not_to allow_value("ftp://example.com/a.png").for(:avatar_url) }
    it { is_expected.not_to allow_value("https://has space.com/a.png").for(:avatar_url) }
  end

  describe "avatar_image" do
    it "accepts an allowed image type" do
      expect(build(:user, :with_avatar_image)).to be_valid
    end

    it "rejects a disallowed content type" do
      user.avatar_image.attach(
        io: Rails.root.join("spec/fixtures/files/document.txt").open,
        filename: "document.txt",
        content_type: "text/plain"
      )

      expect(user).to be_invalid
      expect(user.errors[:avatar_image].join).to match(/content type/i)
    end

    it "rejects a file larger than 5 megabytes" do
      user.avatar_image.attach(
        io: StringIO.new("0" * 6.megabytes),
        filename: "huge.png",
        content_type: "image/png"
      )

      expect(user).to be_invalid
      expect(user.errors[:avatar_image].join).to match(/size|large/i)
    end

    it "skips attachment validation entirely when nothing is attached" do
      expect(user.avatar_image).not_to be_attached
      expect(user).to be_valid
    end
  end

  describe "#avatar_source" do
    it "prefers the attachment when one is present" do
      record = build(:user, :with_avatar_image, :with_avatar_url)

      expect(record.avatar_source).to be_a(ActiveStorage::Attached::One)
      expect(record.avatar_source).to be_attached
    end

    it "falls back to avatar_url when no file is attached" do
      record = build(:user, :with_avatar_url)

      expect(record.avatar_source).to eq("https://cdn.example.com/avatars/ada.png")
    end

    it "returns nil when neither is set" do
      expect(user.avatar_source).to be_nil
    end

    it "returns nil when avatar_url is blank" do
      expect(build(:user, avatar_url: "").avatar_source).to be_nil
    end
  end

  describe "protecting the last administrator" do
    it "refuses to destroy the only admin and reports why" do
      admin = create(:user, :admin)

      expect { admin.destroy }.not_to change(described_class, :count)
      expect(admin.errors[:base]).to include("Cannot remove the last administrator")
    end

    it "returns false from destroy when it aborts" do
      admin = create(:user, :admin)

      expect(admin.destroy).to be(false)
      expect(admin).to be_persisted
    end

    it "runs before dependent: :destroy, so the aborted user keeps their sessions" do
      admin = create(:user, :admin)
      create(:session, user: admin)

      expect { admin.destroy }.not_to change(Session, :count)
      expect(admin.sessions.count).to eq(1)
    end

    it "allows destroying an admin once another admin exists" do
      admin = create(:user, :admin)
      create(:user, :admin)

      expect { admin.destroy }.to change(described_class.admin, :count).from(2).to(1)
    end

    it "never blocks destroying a member" do
      create(:user, :admin)
      member = create(:user)

      expect { member.destroy }.to change(described_class, :count).by(-1)
    end

    it "allows destroying a member even when they are the only user" do
      member = create(:user)

      expect { member.destroy }.to change(described_class, :count).by(-1)
    end

    it "refuses to demote the only admin" do
      admin = create(:user, :admin)

      expect(admin.update(role: :member)).to be(false)
      expect(admin.errors[:role])
        .to include("cannot change: at least one administrator is required")
      expect(admin.reload).to be_admin
    end

    it "allows demoting an admin once another admin exists" do
      admin = create(:user, :admin)
      create(:user, :admin)

      expect(admin.update(role: :member)).to be(true)
      expect(admin.reload).to be_member
    end

    it "does not block an unrelated update to the only admin" do
      admin = create(:user, :admin)

      expect(admin.update(full_name: "Ada Byron")).to be(true)
    end

    it "does not block promoting a member to admin" do
      create(:user, :admin)
      member = create(:user)

      expect(member.update(role: :admin)).to be(true)
    end

    it "never blocks demoting when the record was already a member" do
      create(:user, :admin)
      member = create(:user)

      expect(member.update(role: :member)).to be(true)
    end

    it "does not run on create, so the first user can be a member" do
      expect(build(:user).save).to be(true)
    end
  end

  # The dashboard's counts come straight from these records, so anything that
  # moves them has to reach Dashboard::Broadcaster.
  describe "notifying the dashboard" do
    let(:stream) { Dashboard::Broadcaster::STREAM }

    it "broadcasts when a user is created" do
      expect { create(:user) }.to have_broadcasted_to(stream).with(type: "stats.changed")
    end

    it "broadcasts when a user is destroyed" do
      user = create(:user)

      expect { user.destroy }.to have_broadcasted_to(stream)
    end

    it "broadcasts when a role changes" do
      create(:user, :admin)
      member = create(:user)

      expect { member.update!(role: :admin) }.to have_broadcasted_to(stream)
    end

    it "stays quiet for an update that leaves the counts alone" do
      user = create(:user)

      expect { user.update!(full_name: "Ada Byron") }.not_to have_broadcasted_to(stream)
    end

    it "stays quiet when a save is rolled back" do
      user = build(:user, full_name: "")

      expect { user.save }.not_to have_broadcasted_to(stream)
    end

    describe "while broadcasts are suppressed" do
      it "stays quiet for a create" do
        expect { DashboardBroadcasts.suppress { create(:user) } }.not_to have_broadcasted_to(stream)
      end

      it "stays quiet for a destroy" do
        user = create(:user)

        expect { DashboardBroadcasts.suppress { user.destroy } }.not_to have_broadcasted_to(stream)
      end

      it "stays quiet for a role change" do
        create(:user, :admin)
        member = create(:user)

        expect { DashboardBroadcasts.suppress { member.update!(role: :admin) } }.not_to have_broadcasted_to(stream)
      end

      it "broadcasts again once the block is done" do
        DashboardBroadcasts.suppress { create(:user) }

        expect { create(:user) }.to have_broadcasted_to(stream)
      end
    end
  end
end
