require "rails_helper"

RSpec.describe Imports::CsvRowSet do
  def rows_from(content)
    described_class.new(csv_file(content)).map { |index, row| [ index, row.full_name, row.email_address ] }
  end

  it "yields each data row with a 1-based index" do
    expect(rows_from("name,email\nGrace Hopper,grace@example.com\nAda Lovelace,ada@example.com\n"))
      .to eq([ [ 1, "Grace Hopper", "grace@example.com" ], [ 2, "Ada Lovelace", "ada@example.com" ] ])
  end

  it "builds each row through the header aliases" do
    _index, row = described_class.new(csv_file("Nome,E-mail,Perfil\nGrace Hopper,grace@example.com,admin\n")).first

    expect(row).to be_a(Imports::UserRow)
      .and have_attributes(full_name: "Grace Hopper", email_address: "grace@example.com", role: "admin")
  end

  it "skips blank lines without spending an index on them" do
    rows = rows_from("name,email\n\nGrace Hopper,grace@example.com\n,\nAda Lovelace,ada@example.com\n")

    expect(rows.map(&:first)).to eq([ 1, 2 ])
  end

  it "reads a UTF-8 export that starts with a byte-order mark" do
    expect(rows_from("\uFEFFname,email\nGrace Hopper,grace@example.com\n"))
      .to eq([ [ 1, "Grace Hopper", "grace@example.com" ] ])
  end

  it "tolerates stray quotes inside an unquoted field" do
    expect(rows_from(%(name,email\nGrace "Amazing" Hopper,grace@example.com\n)))
      .to eq([ [ 1, %(Grace "Amazing" Hopper), "grace@example.com" ] ])
  end

  it "returns an enumerator when no block is given" do
    expect(described_class.new(csv_file("name\nGrace Hopper\n")).each).to be_a(Enumerator)
  end

  describe "files it cannot read" do
    it "rejects a header with no recognisable columns" do
      row_set = described_class.new(csv_file("department,office\nEngineering,London\n"))

      expect { row_set.to_a }.to raise_error(Imports::RowSet::MalformedFile, "No recognisable columns found")
    end

    it "reports unparseable CSV as a malformed file" do
      row_set = described_class.new(csv_file(%(name,email\n"Grace Hopper,grace@example.com\n)))

      expect { row_set.to_a }.to raise_error(Imports::RowSet::MalformedFile, /Unclosed quoted field/)
    end

    it "reports text that is not UTF-8 as a malformed file rather than crashing" do
      row_set = described_class.new(csv_file("name,email\nJosé Silva,jose@example.com\n".encode("Windows-1252")))

      expect { row_set.to_a }.to raise_error(Imports::RowSet::MalformedFile, /Invalid byte sequence in UTF-8/)
    end
  end
end
