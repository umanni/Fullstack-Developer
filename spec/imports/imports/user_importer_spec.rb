require "rails_helper"

RSpec.describe Imports::UserImporter do
  subject(:importer) { described_class.new }

  def row(**attributes)
    Imports::UserRow.new(full_name: "Grace Hopper", email_address: "grace@example.com", **attributes)
  end

  describe "a row for a new email address" do
    it "creates the user" do
      result = nil

      expect { result = importer.call(row(role: "admin", avatar_url: "https://cdn.example.com/grace.png")) }
        .to change(User, :count).by(1)

      expect(result).to be_created
      expect(result.errors).to eq([])
      expect(User.find_by(email_address: "grace@example.com"))
        .to have_attributes(full_name: "Grace Hopper", role: "admin", avatar_url: "https://cdn.example.com/grace.png")
    end
  end

  describe "a row for an email address that already has an account" do
    let!(:existing) { create(:user, full_name: "Grace Brewster Hopper", email_address: "grace@example.com") }

    it "skips the row and leaves the account as it was" do
      result = nil

      expect { result = importer.call(row(full_name: "Someone Else", role: "admin")) }.not_to change(User, :count)

      expect(result).to be_skipped
      expect(result.errors).to eq([])
      expect(existing.reload).to have_attributes(full_name: "Grace Brewster Hopper", role: "member")
    end

    it "matches the account regardless of case" do
      expect(importer.call(row(email_address: "GRACE@Example.COM"))).to be_skipped
    end
  end

  describe "a row that fails its own validation" do
    it "reports the row's errors without creating anyone" do
      result = nil

      expect { result = importer.call(row(full_name: "", role: "owner")) }.not_to change(User, :count)

      expect(result).to be_failed
      expect(result.errors).to include("Full name can't be blank", "Role must be admin or member")
    end

    it "never looks the email address up" do
      allow(User).to receive(:find_or_initialize_by)

      importer.call(row(email_address: "not an email"))

      expect(User).not_to have_received(:find_or_initialize_by)
    end
  end

  describe "a row the User model rejects" do
    it "reports the model's errors" do
      user = User.new
      allow(User).to receive(:find_or_initialize_by).and_return(user)
      allow(user).to receive(:save) { user.errors.add(:avatar_image, "is too big") && false }

      result = importer.call(row)

      expect(result).to be_failed
      expect(result.errors).to eq([ "Avatar image is too big" ])
    end
  end

  describe "losing a race on the unique index" do
    it "treats the row as skipped" do
      create(:user, email_address: "grace@example.com")
      fresh = User.new
      allow(User).to receive(:find_or_initialize_by).and_return(fresh)
      # The other writer committed after both our lookup and our uniqueness
      # check, so only the database index is left to stop the insert.
      allow(fresh).to receive(:save).and_wrap_original { |original| original.call(validate: false) }

      result = nil

      expect { result = importer.call(row) }.not_to change(User, :count)
      expect(result).to be_skipped
    end
  end

  describe Imports::UserImporter::Result do
    it "answers true to exactly one outcome predicate" do
      %i[created skipped failed].each do |outcome|
        result = described_class.new(outcome: outcome, errors: [])

        expect([ result.created?, result.skipped?, result.failed? ])
          .to eq(%i[created skipped failed].map { _1 == outcome })
      end
    end
  end
end
