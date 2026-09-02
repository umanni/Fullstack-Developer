require "test_helper"

class Imports::ProgressUpdaterTest < ActiveSupport::TestCase
  test "recalculates durable counters from row states" do
    user_import = create_import
    user_import.update!(status: :processing, total_rows: 3, started_at: Time.current)
    user_import.rows.create!(row_number: 2, payload: { "email" => "a@example.com" }, status: :succeeded)
    user_import.rows.create!(row_number: 3, payload: { "email" => "b@example.com" }, status: :failed)
    user_import.rows.create!(row_number: 4, payload: { "email" => "c@example.com" }, status: :pending)

    Imports::ProgressUpdater.call(user_import)

    user_import.reload
    assert_equal 2, user_import.processed_rows
    assert_equal 1, user_import.succeeded_rows
    assert_equal 1, user_import.failed_rows
  end

  private
    def create_import
      UserImport.create!(created_by: users(:admin), spreadsheet: {
        io: StringIO.new("placeholder"), filename: "users.csv", content_type: "text/csv"
      })
    end
end
