require "test_helper"

class ProcessUserImportJobTest < ActiveJob::TestCase
  test "processes import" do
    import = UserImport.new(created_by: users(:admin), status: :pending)
    import.spreadsheet.attach(
      io: StringIO.new("full_name,email,password\nJob User,jobuser@example.com,password123\n"),
      filename: "users.csv",
      content_type: "text/csv"
    )
    import.save!

    perform_enqueued_jobs only: ProcessUserImportJob

    assert import.reload.completed?
    assert User.exists?(email_address: "jobuser@example.com")
  end
end
