require "test_helper"

class SpreadsheetImport::RowReaderTest < ActiveSupport::TestCase
  test "reads a csv into row attributes" do
    assert_equal expected_rows, rows_from("users.csv", :csv)
  end

  test "reads an xlsx into the same row attributes" do
    assert_equal expected_rows, rows_from("users.xlsx", :xlsx)
  end

  test "counts data rows without the header" do
    assert_equal 5, reader("users.csv", :csv).row_count
  end

  test "numbers rows by their line in the file, header included" do
    lines = []
    reader("users.csv", :csv).each_row { |_attributes, line| lines << line }

    assert_equal [ 2, 3, 4, 5, 6 ], lines
  end

  # Excel adds these without being asked, and counting them makes every one a rejected
  # row and the progress bar wrong.
  test "ignores the empty rows a spreadsheet editor leaves at the end" do
    assert_equal 1, reader("trailing_blank_rows.csv", :csv).row_count
    assert_equal [ 2 ], rows_with_lines("trailing_blank_rows.csv", :csv).map(&:last)
  end

  test "normalises header casing and spacing" do
    path = Rails.root.join("tmp", "odd-headers-#{SecureRandom.hex(4)}.csv")
    path.write("Full Name, EMAIL ,Role\nAda Lovelace,ada@example.com,admin\n")

    attributes = SpreadsheetImport::RowReader.new(path, extension: :csv).to_enum(:each_row).first.first

    assert_equal({ full_name: "Ada Lovelace", email: "ada@example.com", role: "admin" }, attributes)
  ensure
    path&.delete
  end

  private
    def reader(name, extension)
      SpreadsheetImport::RowReader.new(file_fixture(name), extension: extension)
    end

    def rows_with_lines(name, extension)
      [].tap { |rows| reader(name, extension).each_row { |attributes, line| rows << [ attributes, line ] } }
    end

    def rows_from(name, extension)
      [].tap { |rows| reader(name, extension).each_row { |attributes, _line| rows << attributes } }
    end

    def expected_rows
      [
        { full_name: "Katherine Johnson", email: "katherine@umanni.test", role: "admin" },
        { full_name: "Dorothy Vaughan", email: "dorothy@umanni.test", role: "user" },
        { full_name: "Mary Jackson", email: "mary@umanni.test", role: nil },
        { full_name: nil, email: "no-name@umanni.test", role: "user" },
        { full_name: "Duplicate Person", email: "katherine@umanni.test", role: "user" }
      ]
    end
end
