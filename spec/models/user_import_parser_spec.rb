require "rails_helper"

RSpec.describe UserImportParser do
  def parser_for(name, format:)
    described_class.new(path: Rails.root.join("spec/fixtures/files/#{name}").to_s, format: format)
  end

  describe "reading a CSV" do
    subject(:parser) { parser_for("users.csv", format: :csv) }

    it "counts the data rows, not the header" do
      expect(parser.row_count).to eq(3)
    end

    it "yields each row with its line number" do
      numbers = []
      parser.each_row { |number, _attributes| numbers << number }

      expect(numbers).to eq([2, 3, 4])
    end

    it "normalises what it reads" do
      first = nil
      parser.each_row { |_number, attributes| first ||= attributes }

      expect(first).to eq(
        full_name: "Maria Silva",
        email_address: "maria@example.com",
        avatar_url: "https://example.com/maria.png",
        role: "user"
      )
    end

    it "reads a blank cell as nothing rather than an empty string" do
      rows = []
      parser.each_row { |_number, attributes| rows << attributes }

      expect(rows.second[:avatar_url]).to be_nil
    end
  end

  describe "reading an XLSX" do
    subject(:parser) { parser_for("users.xlsx", format: :xlsx) }

    it "counts the data rows" do
      expect(parser.row_count).to eq(3)
    end

    it "reads the same shape as the CSV" do
      rows = []
      parser.each_row { |_number, attributes| rows << attributes }

      expect(rows.first[:full_name]).to eq("Maria Silva")
      expect(rows.last[:role]).to eq("admin")
      expect(rows.pluck(:email_address))
        .to eq(%w[maria@example.com joao@example.com ada.admin@example.com])
    end
  end

  describe "a file it cannot use" do
    it "refuses a header without the columns it needs" do
      parser = parser_for("users-wrong-header.csv", format: :csv)

      expect { parser.row_count }.to raise_error(described_class::UnreadableFile)
    end
  end

  describe "the row ceiling" do
    it "refuses a file with more rows than the limit" do
      stub_const("#{described_class}::MAX_ROWS", 2)
      parser = parser_for("users.csv", format: :csv)

      expect { parser.row_count }.to raise_error(described_class::TooManyRows)
    end
  end
end
