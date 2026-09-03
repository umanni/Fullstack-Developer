require "test_helper"

class Imports::ProcessJobTest < ActiveJob::TestCase
  test "processes every valid row and completes the import" do
    user_import = import_from("valid_users.csv", "text/csv")

    assert_difference "User.count", 2 do
      Imports::ProcessJob.perform_now(user_import)
    end

    user_import.reload
    assert_predicate user_import, :completed?
    assert_equal 2, user_import.total_rows
    assert_equal 2, user_import.processed_rows
    assert_equal 2, user_import.succeeded_rows
    assert_equal 0, user_import.failed_rows
    assert user_import.finished_at
  end

  test "processes a valid XLSX workbook" do
    user_import = import_from(
      "valid_users.xlsx",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

    assert_difference "User.count", 2 do
      Imports::ProcessJob.perform_now(user_import)
    end

    assert_predicate user_import.reload, :completed?
    assert_equal 2, user_import.succeeded_rows
  end

  test "completes with errors while preserving successful rows" do
    csv = <<~CSV
      full_name,email,avatar_image_url,role
      New Person,new-person@example.com,https://example.com/new.png,user
      Existing Person,#{users(:member).email},https://example.com/existing.png,user
    CSV
    user_import = import_from_contents(csv)

    assert_difference "User.count", 1 do
      Imports::ProcessJob.perform_now(user_import)
    end

    user_import.reload
    assert_predicate user_import, :completed_with_errors?
    assert_equal 1, user_import.succeeded_rows
    assert_equal 1, user_import.failed_rows
    assert_match "already been taken", user_import.rows.failed.first.error_message
  end

  test "marks a structurally invalid spreadsheet as failed" do
    user_import = import_from_contents("full_name,email\nAda,ada@example.com\n")

    assert_no_difference "User.count" do
      Imports::ProcessJob.perform_now(user_import)
    end

    assert_predicate user_import.reload, :failed?
    assert_match "Missing required columns", user_import.failure_message
  end

  test "is idempotent after reaching a terminal state" do
    user_import = import_from("valid_users.csv", "text/csv")
    user_import.update!(status: :completed, finished_at: Time.current)

    assert_no_difference [ "User.count", "UserImportRow.count" ] do
      Imports::ProcessJob.perform_now(user_import)
    end
  end

  test "records a safe failure after the final retry of an unexpected error" do
    user_import = import_from("valid_users.csv", "text/csv")
    blob = user_import.spreadsheet.blob
    blob.service.delete(blob.key)
    job = Imports::ProcessJob.new(user_import)
    job.exception_executions[[ StandardError ].to_s] = 2

    assert_error_reported(ActiveStorage::FileNotFoundError) do
      assert_no_enqueued_jobs do
        assert_raises(ActiveStorage::FileNotFoundError) { job.perform_now }
      end
    end

    user_import.reload
    assert_predicate user_import, :failed?
    assert_equal "The import could not be completed after multiple attempts.", user_import.failure_message
    assert_not_includes user_import.failure_message, blob.key
    assert user_import.finished_at
  end

  private
    def import_from(filename, content_type)
      UserImport.create!(created_by: users(:admin), spreadsheet: {
        io: File.open(file_fixture(filename)), filename:, content_type:
      })
    end

    def import_from_contents(contents)
      UserImport.create!(created_by: users(:admin), spreadsheet: {
        io: StringIO.new(contents), filename: "users.csv", content_type: "text/csv"
      })
    end
end
