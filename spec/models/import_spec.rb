require "rails_helper"

RSpec.describe Import, type: :model do
  subject(:import) { build(:import) }

  def attach_file(record, content: "full_name\n", filename: "users.csv", content_type: "text/csv")
    record.file.attach(io: StringIO.new(content), filename: filename, content_type: content_type, identify: false)
  end

  it "has a valid factory" do
    expect(import).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }

    it "is destroyed along with its user" do
      # A member owner on purpose: the factory's default owner is an admin, and
      # the last admin cannot be destroyed at all.
      import = create(:import, user: create(:user))

      expect { import.user.destroy }.to change(described_class, :count).by(-1)
    end
  end

  describe "status" do
    it do
      expect(import).to define_enum_for(:status)
        .with_values(pending: 0, parsing: 1, processing: 2, completed: 3, failed: 4, cancelled: 5)
        .validating
    end

    it "starts out pending" do
      expect(described_class.new).to be_pending
    end
  end

  describe "file" do
    it "is required" do
      import = described_class.new(user: build(:user))

      expect(import).to be_invalid
      expect(import.errors[:file]).to include("can't be blank")
    end

    it "accepts an xlsx workbook" do
      attach_file(import, filename: "users.xlsx", content_type: Import::CONTENT_TYPES.key(:xlsx))

      expect(import).to be_valid
    end

    it "rejects any other content type" do
      attach_file(import, filename: "notes.txt", content_type: "text/plain")

      expect(import).to be_invalid
      expect(import.errors[:file]).to include("must be a .csv or .xlsx file")
    end

    it "accepts a file of exactly the size limit" do
      attach_file(import, content: "a" * Import::MAX_FILE_SIZE)

      expect(import).to be_valid
    end

    it "rejects a file over the size limit" do
      attach_file(import, content: "a" * (Import::MAX_FILE_SIZE + 1))

      expect(import).to be_invalid
      expect(import.errors[:file]).to include("must be smaller than 10 MB")
    end
  end

  describe ".recent" do
    it "orders newest first" do
      older = create(:import, created_at: 2.days.ago)
      newer = create(:import, created_at: 1.hour.ago)

      expect(described_class.recent).to eq([ newer, older ])
    end
  end

  describe "#format" do
    it "is :csv for a CSV upload" do
      expect(import.format).to eq(:csv)
    end

    it "is :xlsx for a workbook upload" do
      attach_file(import, filename: "users.xlsx", content_type: Import::CONTENT_TYPES.key(:xlsx))

      expect(import.format).to eq(:xlsx)
    end

    it "falls back to :csv for an unrecognised content type" do
      attach_file(import, filename: "notes.txt", content_type: "text/plain")

      expect(import.format).to eq(:csv)
    end
  end

  describe "#progress" do
    it "is 0 before any rows have been counted" do
      expect(build(:import, total_rows: 0, processed_rows: 0).progress).to eq(0)
    end

    it "rounds to a whole percentage" do
      expect(build(:import, total_rows: 3, processed_rows: 1).progress).to eq(33)
      expect(build(:import, total_rows: 3, processed_rows: 2).progress).to eq(67)
    end

    it "is 100 once every row is processed" do
      expect(build(:import, total_rows: 40, processed_rows: 40).progress).to eq(100)
    end
  end

  describe "#finished?" do
    %i[completed failed cancelled].each do |status|
      it "is true when #{status}" do
        expect(build(:import, status: status)).to be_finished
      end
    end

    %i[pending parsing processing].each do |status|
      it "is false when #{status}" do
        expect(build(:import, status: status)).not_to be_finished
      end
    end
  end

  describe "#record_error" do
    # In-place `<<` on a jsonb column only persists if Active Record notices the
    # mutation, so these go through a save and reload rather than trusting memory.
    it "appends a row entry that survives a save" do
      import = create(:import)

      import.record_error(2, "grace@example.com", "Email address has already been taken")
      import.save!

      expect(import.reload.error_report).to eq([
        { "row" => 2, "identifier" => "grace@example.com", "errors" => [ "Email address has already been taken" ] }
      ])
    end

    it "keeps a list of messages as a list" do
      import.record_error(3, nil, [ "Full name can't be blank", "Email address is invalid" ])

      expect(import.error_report.last[:errors]).to eq([ "Full name can't be blank", "Email address is invalid" ])
    end

    it "stops recording once the report is full" do
      (Import::MAX_REPORTED_ROWS + 5).times { |i| import.record_error(i, "row#{i}", "bad") }

      expect(import.error_report.size).to eq(Import::MAX_REPORTED_ROWS)
      expect(import.error_report.last[:row]).to eq(Import::MAX_REPORTED_ROWS - 1)
    end
  end
end
