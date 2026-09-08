require "test_helper"

class ProcessUserImportJobTest < ActiveJob::TestCase
  setup { clear_enqueued_jobs }

  test "creates valid users, rows, emails, and final statistics" do
    user_import = create_user_import

    assert_difference "User.count", 2 do
      assert_enqueued_emails 2 do
        ProcessUserImportJob.perform_now(user_import)
      end
    end

    user_import.reload
    assert_predicate user_import, :completed?
    assert_equal 2, user_import.total_rows
    assert_equal 2, user_import.processed_rows
    assert_equal 2, user_import.successful_rows
    assert_equal 0, user_import.failed_rows
    assert_equal 2, user_import.rows.succeeded.count
    assert_enqueued_jobs 1, only: UserStatisticsBroadcastJob
  end

  test "records invalid rows without aborting the batch" do
    csv = <<~CSV
      full_name,email,role
      Existing User,linus@example.com,user
      Valid User,valid-import@example.com,user
      Invalid Role,role@example.com,owner
    CSV
    user_import = create_user_import(contents: csv)

    assert_difference "User.count", 1 do
      ProcessUserImportJob.perform_now(user_import)
    end

    user_import.reload
    assert_predicate user_import, :completed_with_errors?
    assert_equal 3, user_import.processed_rows
    assert_equal 1, user_import.successful_rows
    assert_equal 2, user_import.failed_rows
    assert_match(/taken/, user_import.rows.failed.find_by(row_number: 2).error_message)
    assert_match(/included/, user_import.rows.failed.find_by(row_number: 4).error_message)
  end

  test "fails cleanly when spreadsheet structure is invalid" do
    user_import = create_user_import(contents: "wrong,headers\nOne,Two\n")

    assert_no_difference "User.count" do
      ProcessUserImportJob.perform_now(user_import)
    end

    assert_predicate user_import.reload, :failed?
    assert_match(/Missing required columns/, user_import.failure_message)
  end

  test "a completed import is idempotent" do
    user_import = create_user_import
    ProcessUserImportJob.perform_now(user_import)

    assert_no_difference [ "User.count", "UserImportRow.count" ] do
      ProcessUserImportJob.perform_now(user_import.reload)
    end
  end
end
