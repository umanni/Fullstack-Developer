require "test_helper"

class UserImportTest < ActiveSupport::TestCase
  test "progress is a zero-safe 0..1 share" do
    user_import = user_imports(:one)
    user_import.update!(processed_rows: 1, total_rows: 2)
    assert_in_delta 0.5, user_import.progress

    user_import.update!(total_rows: 0, processed_rows: 0)
    assert_equal 0.0, user_import.progress
  end

  test "requires a file on create" do
    user_import = UserImport.new(user: users(:one), status: :pending)

    assert_not user_import.valid?
    assert_includes user_import.errors[:file], "can't be blank"
  end

  test "accepts supported spreadsheet formats" do
    %w[users.csv users.xlsx users.xls].each do |name|
      user_import = build_with_file(name)

      assert user_import.valid?, "#{name} should be accepted: #{user_import.errors[:file].inspect}"
    end
  end

  test "rejects unsupported file formats" do
    user_import = build_with_file("users.pdf")

    assert_not user_import.valid?
    assert_includes user_import.errors[:file], "must be a .csv, .xlsx or .xls file"
  end

  private

  def build_with_file(filename)
    UserImport.new(user: users(:one), status: :pending).tap do |record|
      record.file.attach(
        io: StringIO.new("Full name,Email address\n"),
        filename: filename,
        content_type: "text/csv"
      )
    end
  end
end
