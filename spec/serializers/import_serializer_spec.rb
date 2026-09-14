require "rails_helper"

RSpec.describe ImportSerializer do
  describe "#as_json" do
    it "exposes the import's status, progress and tallies" do
      import = create(:import, status: :processing, total_rows: 4, processed_rows: 3,
                               created_count: 2, skipped_count: 1, failed_count: 0)

      expect(described_class.new(import).as_json).to include(
        id: import.id, status: "processing", filename: "users.csv", progress: 75,
        total_rows: 4, processed_rows: 3, created_count: 2, skipped_count: 1, failed_count: 0,
        failure_reason: nil, finished: false, created_at: import.created_at.iso8601
      )
    end

    it "marks a failed import as finished and carries the reason" do
      import = create(:import, status: :failed, failure_reason: "No recognisable columns found")

      expect(described_class.new(import).as_json)
        .to include(finished: true, failure_reason: "No recognisable columns found")
    end

    it "sends only the first 50 rejected rows" do
      import = build(:import)
      60.times { |i| import.record_error(i + 1, "row#{i + 1}@example.com", "Email address is invalid") }
      import.save!

      report = described_class.new(import.reload).as_json[:error_report]

      expect(report.size).to eq(50)
      expect(report.first)
        .to eq("row" => 1, "identifier" => "row1@example.com", "errors" => [ "Email address is invalid" ])
    end
  end

  describe ".collection" do
    it "serializes each import in order" do
      imports = create_list(:import, 2)

      expect(described_class.collection(imports).pluck(:id)).to eq(imports.map(&:id))
    end
  end
end
