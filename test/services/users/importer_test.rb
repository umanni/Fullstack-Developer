require "test_helper"
require "tempfile"

module Users
  class ImporterTest < ActiveSupport::TestCase
    test "imports users from csv" do
      import = create_import(<<~CSV)
        full_name,email,password,role
        Imported One,imported1@example.com,password123,member
        Imported Two,imported2@example.com,password123,admin
      CSV

      result = Users::Importer.call(import)

      assert_equal 2, result.successful
      assert_equal 0, result.failed
      assert import.reload.completed?
      assert User.exists?(email_address: "imported1@example.com")
      assert User.find_by(email_address: "imported2@example.com").admin?
    end

    test "tracks failed rows" do
      import = create_import(<<~CSV)
        full_name,email,password
        Bad User,not-an-email,password123
      CSV

      result = Users::Importer.call(import)

      assert_equal 0, result.successful
      assert_equal 1, result.failed
      assert import.reload.completed?
    end

    private

    def create_import(csv_body)
      import = UserImport.new(created_by: users(:admin), status: :pending)
      file = Tempfile.new([ "users", ".csv" ])
      file.write(csv_body)
      file.rewind
      import.spreadsheet.attach(
        io: file,
        filename: "users.csv",
        content_type: "text/csv"
      )
      import.save!
      file.close!
      import
    end
  end
end
