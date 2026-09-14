require "rails_helper"

RSpec.describe Imports::SpreadsheetRowSet do
  def rows_from(rows)
    described_class.new(xlsx_file(rows)).map { |index, row| [ index, row.full_name, row.email_address, row.role ] }
  end

  it "yields each data row with a 1-based index, built through the header aliases" do
    rows = rows_from([
      [ "Nome", "E-mail", "Perfil" ],
      [ "Grace Hopper", "grace@example.com", "admin" ],
      [ "Ada Lovelace", "ada@example.com", "member" ]
    ])

    expect(rows).to eq([
      [ 1, "Grace Hopper", "grace@example.com", "admin" ],
      [ 2, "Ada Lovelace", "ada@example.com", "member" ]
    ])
  end

  it "skips blank rows without spending an index on them" do
    rows = rows_from([
      %w[name email],
      [ "Grace Hopper", "grace@example.com" ],
      [ nil, nil ],
      [ "", "" ],
      [ "Ada Lovelace", "ada@example.com" ]
    ])

    expect(rows.map(&:first)).to eq([ 1, 2 ])
  end

  it "keeps later cells in their own column when a row leaves one out" do
    expect(rows_from([ %w[name email role], [ "Ada Lovelace", nil, "admin" ] ]))
      .to eq([ [ 1, "Ada Lovelace", nil, "admin" ] ])
  end

  it "turns numeric cells into text" do
    expect(rows_from([ %w[name email], [ 42, "answer@example.com" ] ]))
      .to eq([ [ 1, "42", "answer@example.com", "member" ] ])
  end

  it "returns an enumerator when no block is given" do
    expect(described_class.new(xlsx_file([ %w[name] ])).each).to be_a(Enumerator)
  end

  describe "files it cannot read" do
    it "rejects a header with no recognisable columns" do
      row_set = described_class.new(xlsx_file([ %w[department office], %w[Engineering London] ]))

      expect { row_set.to_a }.to raise_error(Imports::RowSet::MalformedFile, "No recognisable columns found")
    end

    it "reports a file that is not really a workbook as a malformed file" do
      row_set = described_class.new(csv_file("name,email\n", name: "users.xlsx"))

      expect { row_set.to_a }.to raise_error(Imports::RowSet::MalformedFile, /end of central directory/)
    end
  end
end
