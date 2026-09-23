require "test_helper"
require "tempfile"

class SpreadsheetUserImporterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "imports users from csv" do
    import = build_import(<<~CSV)
      full_name,email,role
      Imported One,one@import.test,no-admin
      Imported Two,two@import.test,admin
    CSV

    SpreadsheetUserImporter.new(import).call

    import.reload
    assert_equal "completed", import.status
    assert_equal 2, import.success_count
    assert User.exists?(email: "one@import.test")
    assert User.find_by(email: "two@import.test").admin?
  end

  test "records row failures without aborting" do
    import = build_import(<<~CSV)
      full_name,email
      Valid Person,valid@import.test
      ,missing-name@import.test
    CSV

    SpreadsheetUserImporter.new(import).call
    import.reload
    assert_equal "completed", import.status
    assert_equal 1, import.success_count
    assert_equal 1, import.failure_count
  end

  private

  def build_import(csv_body)
    import = users(:admin).imports.build(filename: "users.csv", status: "pending")
    tempfile = Tempfile.new([ "users", ".csv" ])
    tempfile.write(csv_body)
    tempfile.rewind
    import.spreadsheet.attach(
      io: tempfile,
      filename: "users.csv",
      content_type: "text/csv"
    )
    import.save!
    import
  end
end
