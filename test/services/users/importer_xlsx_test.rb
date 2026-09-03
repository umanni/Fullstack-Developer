require "test_helper"
require "caxlsx"

module Users
  class ImporterXlsxTest < ActiveSupport::TestCase
    test "imports users from xlsx workbook" do
      path = Rails.root.join("tmp", "import_users.xlsx")
      FileUtils.mkdir_p(path.dirname)

      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: "Users") do |sheet|
          sheet.add_row %w[full_name email password role]
          sheet.add_row [ "Xlsx One", "xlsx1@example.com", "password123", "member" ]
          sheet.add_row [ "Xlsx Two", "xlsx2@example.com", "password123", "admin" ]
        end
        package.serialize(path.to_s)
      end

      import = UserImport.new(created_by: users(:admin), status: :pending)
      import.spreadsheet.attach(
        io: File.open(path),
        filename: "import_users.xlsx",
        content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )
      import.save!

      result = Users::Importer.call(import)

      assert_equal 2, result.successful
      assert_equal 0, result.failed
      assert_predicate import.reload, :completed?
      assert User.exists?(email_address: "xlsx1@example.com")
      assert_predicate User.find_by(email_address: "xlsx2@example.com"), :admin?
    ensure
      FileUtils.rm_f(path) if path
    end
  end
end
