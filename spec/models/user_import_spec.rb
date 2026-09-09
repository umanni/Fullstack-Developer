require "rails_helper"

RSpec.describe UserImport do
  def upload(name, content_type: "text/csv")
    Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/#{name}"), content_type)
  end

  def build_import(file_name, **)
    build(:user_import, **).tap { |import| import.file.attach(upload(file_name)) }
  end

  describe "the attached file" do
    it "accepts a CSV" do
      expect(build_import("users.csv")).to be_valid
    end

    it "accepts an XLSX" do
      expect(build_import("users.xlsx")).to be_valid
    end

    it "requires a file" do
      expect(build(:user_import)).not_to be_valid
    end

    it "refuses an extension it cannot parse" do
      import = build(:user_import)
      import.file.attach(upload("avatar.png", content_type: "image/png"))

      expect(import).not_to be_valid
    end

    # Renaming a binary to .csv should not get it past the gate.
    it "refuses content that does not match the extension" do
      import = build(:user_import)
      import.file.attach(
        Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/avatar.png"), "text/csv",
                                     original_filename: "users.csv")
      )

      expect(import).not_to be_valid
    end
  end

  describe "who asked for it" do
    it "records the address at the time, so it outlives the account" do
      administrator = create(:user, :admin, full_name: "Grace Hopper",
                                            email_address: "grace@example.com")
      import = create(:user_import, :with_csv, administrator: administrator)
      create(:user, :admin) # the last-administrator rule is not what is under test

      expect(import.requested_by).to eq("Grace Hopper")

      administrator.destroy!

      expect(import.reload.administrator).to be_nil
      expect(import.requested_by).to eq("grace@example.com")
    end
  end

  describe "#format" do
    it "reads the format from the extension" do
      expect(build_import("users.csv").format).to eq(:csv)
      expect(build_import("users.xlsx").format).to eq(:xlsx)
    end
  end

  describe "progress" do
    it "is zero before anything has been counted" do
      expect(build(:user_import, total_rows: 0, processed_rows: 0).progress_percentage).to be_zero
    end

    it "reports how far through the rows it is" do
      import = build(:user_import, total_rows: 8, processed_rows: 2)

      expect(import.progress_percentage).to eq(25)
    end

    it "never reports more than complete" do
      import = build(:user_import, total_rows: 4, processed_rows: 9)

      expect(import.progress_percentage).to eq(100)
    end
  end

  describe "#finished?" do
    it "is false while the work is still ahead or underway" do
      expect(build(:user_import, status: :pending)).not_to be_finished
      expect(build(:user_import, status: :processing)).not_to be_finished
    end

    it "is true once it has come to rest, however it ended" do
      expect(build(:user_import, status: :completed)).to be_finished
      expect(build(:user_import, status: :completed_with_errors)).to be_finished
      expect(build(:user_import, status: :failed)).to be_finished
    end
  end
end
