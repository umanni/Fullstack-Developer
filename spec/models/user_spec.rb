require "rails_helper"

RSpec.describe User do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_length_of(:full_name).is_at_most(120) }
    it { is_expected.to validate_presence_of(:email_address) }

    it "rejects an email address without a domain" do
      user = build(:user, email_address: "maria@")

      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to be_present
    end

    it "accepts a conventional email address" do
      expect(build(:user, email_address: "maria.silva@example.com")).to be_valid
    end
  end

  describe "normalization" do
    it "downcases and strips the email address" do
      user = create(:user, email_address: "  Maria.Silva@Example.COM  ")

      expect(user.email_address).to eq("maria.silva@example.com")
    end

    it "collapses whitespace in the full name" do
      user = create(:user, full_name: "  Maria   Silva  ")

      expect(user.full_name).to eq("Maria Silva")
    end
  end

  describe "email uniqueness" do
    it "rejects a duplicate regardless of case" do
      create(:user, email_address: "maria@example.com")
      duplicate = build(:user, email_address: "MARIA@EXAMPLE.COM")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email_address]).to be_present
    end

    it "is enforced by the database, not only by the model" do
      create(:user, email_address: "maria@example.com")
      duplicate = build(:user, email_address: "MARIA@EXAMPLE.COM")

      expect { duplicate.save!(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "roles" do
    it "defines the user and admin roles" do
      expect(described_class.roles.keys).to contain_exactly("user", "admin")
    end

    it "defaults to the user role" do
      expect(described_class.new.role).to eq("user")
    end

    it "exposes a predicate for each role" do
      expect(build(:user, :admin)).to be_admin
      expect(build(:user)).not_to be_admin
    end
  end

  describe "password" do
    it "authenticates with the correct password" do
      user = create(:user, password: "correct horse battery")

      expect(user.authenticate("correct horse battery")).to eq(user)
      expect(user.authenticate("wrong")).to be(false)
    end
  end

  describe "locale" do
    it "defaults to English" do
      expect(described_class.new.locale).to eq("en")
    end

    it "accepts every supported locale" do
      User::SUPPORTED_LOCALES.each do |locale|
        expect(build(:user, locale: locale)).to be_valid
      end
    end

    it "rejects a locale the application does not support" do
      expect(build(:user, locale: "de")).not_to be_valid
    end
  end
end
