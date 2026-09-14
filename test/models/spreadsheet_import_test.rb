require "test_helper"

class SpreadsheetImportTest < ActiveSupport::TestCase
  test "rejects a file over the size cap" do
    import = build
    import.file.attach(
      io: StringIO.new("full_name,email,role\n" + ("x" * SpreadsheetImport::MAX_FILE_SIZE)),
      filename: "big.csv"
    )

    assert_predicate import, :invalid?
    assert_includes import.errors[:file], "must be under 5 MB"
  end

  # The form's required attribute keeps a browser from reaching this, so the model is
  # the only thing standing between a console or a script and an import with no file.
  test "rejects a record with no file at all" do
    import = build

    assert_predicate import, :invalid?
    assert_includes import.errors[:file], "must be attached"
  end

  test "rejects an extension no spreadsheet reader understands" do
    import = build
    import.file.attach(io: StringIO.new("a,b"), filename: "users.numbers")

    assert_predicate import, :invalid?
    assert_includes import.errors[:file], "must be a .csv or .xlsx file"
  end

  # Rejecting it here keeps it out of the queue. A job that fails before the browser has
  # subscribed to the stream leaves the page showing "Pending" until a reload.
  test "rejects a file with nothing in it" do
    import = build
    import.file.attach(io: StringIO.new(""), filename: "empty.csv")

    assert_predicate import, :invalid?
    assert_includes import.errors[:file], "is empty"
  end

  # The bar reads this before the job has counted anything.
  test "reports no progress before the row count is known" do
    assert_equal 0, build.progress
  end

  test "counts the rows that were not rejected as imported" do
    import = build(processed_rows: 30, failed_rows: 4)

    assert_equal 26, import.imported_rows
  end

  private
    def build(**attributes)
      users(:admin).spreadsheet_imports.build(**attributes)
    end
end
