require "test_helper"

class UserImportJobExtraTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test "counts blank emails as failed" do
    import = UserImport.new(status: :pending, total_rows: 0, processed_rows: 0, failed_rows: 0)
    import.file.attach(
      io: StringIO.new("full_name,email,password\nBlank,,Password123\nOk,ok-blank@example.com,Password123\n"),
      filename: "blank.csv",
      content_type: "text/csv"
    )
    import.save!

    perform_enqueued_jobs { UserImportJob.perform_later(import) }

    import.reload
    assert_equal "completed", import.status
    assert_equal 2, import.total_rows
    assert_equal 1, import.processed_rows
    assert_equal 1, import.failed_rows
  end

  test "counts invalid records as failed" do
    User.create!(full_name: "Taken", email: "taken@example.com", password: "Password123", password_confirmation: "Password123")

    import = UserImport.new(status: :pending, total_rows: 0, processed_rows: 0, failed_rows: 0)
    import.file.attach(
      io: StringIO.new("full_name,email,password\nDupe,taken@example.com,Password123\n"),
      filename: "dupe.csv",
      content_type: "text/csv"
    )
    import.save!

    perform_enqueued_jobs { UserImportJob.perform_later(import) }

    import.reload
    assert_equal "failed", import.status
    assert_equal 1, import.total_rows
    assert_equal 0, import.processed_rows
    assert_equal 1, import.failed_rows
  end
end
