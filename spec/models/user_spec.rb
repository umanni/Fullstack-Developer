require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    it "requires a full name" do
      user.full_name = nil
      expect(user).not_to be_valid
      expect(user.errors[:full_name]).to include("can't be blank")
    end

    it "requires an email" do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "requires a unique email" do
      create(:user, email: "test@example.com")
      duplicate = build(:user, email: "test@example.com")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end
  end

  describe "password validations" do
    it "requires a password on create" do
      new_user = User.new(full_name: "Test", email: "test@example.com", password: nil)
      expect(new_user).not_to be_valid
    end

    it "allows no password on update" do
      saved = create(:user)
      saved.full_name = "Updated Name"

      expect(saved.valid?).to be true
    end
  end

  describe "avatar validations" do
    it "accepts valid image types" do
      user.avatar.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "avatar.png")),
        filename: "avatar.png",
        content_type: "image/png"
      )

      expect(user).to be_valid
    end

    it "rejects invalid file types" do
      user.avatar.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "users.csv")),
        filename: "users.csv",
        content_type: "text/csv"
      )

      expect(user).not_to be_valid
      expect(user.errors[:avatar]).to include("must be a PNG, JPG, or JPEG")
    end

    it "rejects files over 5MB" do
      # Create a fake large file in memory
      large_file = Tempfile.new("large.jpg")
      large_file.write("0" * 6.megabytes)
      large_file.rewind

      user.avatar.attach(
        io: large_file,
        filename: "large.jpg",
        content_type: "image/jpeg"
      )

      expect(user).not_to be_valid
      expect(user.errors[:avatar]).to include("maximum size allowed is 5MB")

      large_file.close
      large_file.unlink
    end
  end
end
