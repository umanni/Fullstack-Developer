require "test_helper"

class UserImportJobIdempotencyTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test "resumes from the processed cursor instead of recreating users" do
    csv = "full_name,email,password\nOne,resume-one@example.com,Password123\nTwo,resume-two@example.com,Password123\n"
    import = UserImport.new(status: :processing, total_rows: 2, processed_rows: 1, failed_rows: 0)
    import.file.attach(io: StringIO.new(csv), filename: "resume.csv", content_type: "text/csv")
    import.save!

    # Simulate the first row created by the previous attempt before it crashed.
    User.create!(full_name: "One", email: "resume-one@example.com", password: "Password123", password_confirmation: "Password123")

    assert_difference("User.count", 1) { UserImportJob.new.perform(import) }

    import.reload
    assert_equal "completed", import.status
    assert_equal 2, import.processed_rows
    assert_equal 0, import.failed_rows
    assert User.exists?(email: "resume-two@example.com")
  end

  test "does nothing when the import already completed" do
    import = UserImport.new(status: :completed, total_rows: 1, processed_rows: 1, failed_rows: 0)
    import.file.attach(
      io: StringIO.new("full_name,email,password\nDone,already-done@example.com,Password123\n"),
      filename: "done.csv",
      content_type: "text/csv"
    )
    import.save!

    assert_no_difference("User.count") { UserImportJob.new.perform(import) }

    assert_equal "completed", import.reload.status
  end
end
