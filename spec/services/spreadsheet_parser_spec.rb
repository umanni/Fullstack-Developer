require "rails_helper"

RSpec.describe SpreadsheetParser do
  def spreadsheet_import_with(fixture_name, content_type, **attrs)
    spreadsheet_import = create(:spreadsheet_import, **attrs)
    spreadsheet_import.file.attach(
      io: File.open(Rails.root.join("spec/fixtures/files", fixture_name)),
      filename: fixture_name,
      content_type: content_type
    )
    spreadsheet_import
  end

  describe "#rows" do
    it "maps columns positionally: 1st column is always the name, 2nd is always the email" do
      spreadsheet_import = spreadsheet_import_with("valid_import.csv", "text/csv")

      rows = described_class.new(spreadsheet_import).rows

      expect(rows).to include([ 2, { "nome" => "Alice Example", "email" => "alice@example.com" } ])
    end

    it "never uses the header row's own text to map columns, even when it doesn't say nome/email" do
      spreadsheet_import = spreadsheet_import_with("header_labels_mismatch_import.csv", "text/csv", has_header: true)

      rows = described_class.new(spreadsheet_import).rows

      expect(rows).to eq([ [ 2, { "nome" => "Henry Example", "email" => "henry@example.com" } ] ])
    end

    it "treats the first row as real data (positionally) when has_header is false" do
      spreadsheet_import = spreadsheet_import_with("valid_import_no_header.csv", "text/csv", has_header: false)

      rows = described_class.new(spreadsheet_import).rows

      expect(rows).to eq([
        [ 1, { "nome" => "Frank Example", "email" => "frank@example.com" } ],
        [ 2, { "nome" => "Grace Example", "email" => "grace@example.com" } ]
      ])
    end

    it "skips blank rows" do
      spreadsheet_import = spreadsheet_import_with("mixed_import.csv", "text/csv")

      rows = described_class.new(spreadsheet_import).rows

      expect(rows.map(&:first)).to eq([ 2, 3, 4, 5, 6 ])
    end

    it "reads both CSV and XLSX through the same API" do
      csv_rows = described_class.new(spreadsheet_import_with("mixed_import.csv", "text/csv")).rows
      xlsx_rows = described_class.new(
        spreadsheet_import_with("mixed_import.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      ).rows

      expect(xlsx_rows).to eq(csv_rows)
    end

    it "raises a ParseError instead of a raw parsing exception when the file is malformed" do
      spreadsheet_import = spreadsheet_import_with("malformed_import.csv", "text/csv")

      expect { described_class.new(spreadsheet_import).rows }.to raise_error(described_class::ParseError)
    end
  end
end
