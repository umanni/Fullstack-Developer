require "test_helper"

class UserImportTest < ActiveSupport::TestCase
  test "file_name returns attached filename" do
    import = UserImport.new(status: :pending, total_rows: 0, processed_rows: 0, failed_rows: 0)
    import.file.attach(io: StringIO.new("full_name,email,password\n"), filename: "XXX_USERS_.csv", content_type: "text/csv")

    assert_equal "XXX_USERS_.csv", import.file_name
  end

  test "file_name returns nil without attachment" do
    import = UserImport.new(status: :pending, total_rows: 0, processed_rows: 0, failed_rows: 0)

    assert_nil import.file_name
  end

  test "requires file" do
    import = UserImport.new(status: :pending, total_rows: 0, processed_rows: 0, failed_rows: 0)

    assert_not import.valid?
    assert_includes import.errors[:file], "can't be blank"
  end
end
