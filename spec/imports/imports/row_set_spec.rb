require "rails_helper"

RSpec.describe Imports::RowSet do
  describe ".for" do
    it "reads a workbook upload as a spreadsheet" do
      import = build(:import)
      import.file.attach(io: StringIO.new(""), filename: "users.xlsx",
                         content_type: Import::CONTENT_TYPES.key(:xlsx), identify: false)

      expect(described_class.for(import, "users.xlsx")).to be_a(Imports::SpreadsheetRowSet)
    end

    it "reads a CSV upload as CSV" do
      expect(described_class.for(build(:import), "users.csv")).to be_a(Imports::CsvRowSet)
    end
  end

  describe "#count" do
    it "counts data rows, leaving out the header and blank lines" do
      path = csv_file("name,email\nGrace Hopper,grace@example.com\n\nAda Lovelace,ada@example.com\n")

      expect(Imports::CsvRowSet.new(path).count).to eq(2)
    end

    it "reads the file once however often it is asked" do
      row_set = Imports::CsvRowSet.new(csv_file("name\nGrace Hopper\n"))

      allow(CSV).to receive(:foreach).and_call_original

      expect(2.times.map { row_set.count }).to eq([ 1, 1 ])
      expect(CSV).to have_received(:foreach).once
    end
  end
end
