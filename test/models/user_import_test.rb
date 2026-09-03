require "test_helper"

class UserImportTest < ActiveSupport::TestCase
  test "progress percent" do
    import = UserImport.new(total_rows: 10, processed_rows: 5)
    assert_equal 50, import.progress_percent
  end

  test "finished states" do
    assert UserImport.new(status: :completed).finished?
    assert UserImport.new(status: :failed).finished?
    assert_not UserImport.new(status: :pending).finished?
  end

  test "rejects unsupported spreadsheet types" do
    import = UserImport.new(created_by: users(:admin))
    import.spreadsheet.attach(
      io: StringIO.new("hello"),
      filename: "notes.txt",
      content_type: "text/plain"
    )
    assert_not import.valid?
    assert_includes import.errors[:spreadsheet], "must be a .csv or .xlsx file"
  end
end
