require "test_helper"

class Imports::RowProcessorTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "creates an invited user and marks the row successful" do
    row = import_row(email: "imported@example.com", role: "admin")

    assert_enqueued_emails 1 do
      assert_difference "User.count", 1 do
        Imports::RowProcessor.call(row)
      end
    end

    assert_predicate row.reload, :succeeded?
    assert_predicate row.user, :admin?
    assert_nil row.error_message
  end

  test "maps no-admin to the standard user role" do
    row = import_row(email: "standard@example.com", role: "no-admin")

    Imports::RowProcessor.call(row)

    assert_predicate row.reload.user, :user?
  end

  test "isolates validation errors on a row" do
    row = import_row(email: users(:member).email)

    assert_no_difference "User.count" do
      Imports::RowProcessor.call(row)
    end

    assert_predicate row.reload, :failed?
    assert_match "Email has already been taken", row.error_message
  end

  test "rejects an unsupported role without creating a user" do
    row = import_row(email: "invalid-role@example.com", role: "owner")

    assert_no_difference "User.count" do
      Imports::RowProcessor.call(row)
    end

    assert_predicate row.reload, :failed?
    assert_match "Role must be", row.error_message
  end

  private
    def import_row(email:, role: "user")
      user_import = UserImport.create!(created_by: users(:admin), spreadsheet: {
        io: StringIO.new("placeholder"), filename: "users.csv", content_type: "text/csv"
      })
      user_import.rows.create!(row_number: 2, payload: {
        "full_name" => "Imported Person",
        "email" => email,
        "avatar_image_url" => "https://example.com/imported.png",
        "role" => role
      })
    end
end
