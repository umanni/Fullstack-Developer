require "test_helper"

class UserImportRowErrorsTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test "collects per-row errors with row numbers and messages" do
    User.create!(full_name: "Taken", email: "taken@example.com", password: "Password123", password_confirmation: "Password123")

    import = UserImport.new(status: :pending, total_rows: 0, processed_rows: 0, failed_rows: 0)
    import.file.attach(
      io: StringIO.new("full_name,email,password\nBlank,,Password123\nDupe,taken@example.com,Password123\nOk,ok-rows@example.com,Password123\n"),
      filename: "errors.csv",
      content_type: "text/csv"
    )
    import.save!

    perform_enqueued_jobs { UserImportJob.perform_later(import) }

    import.reload
    assert_equal 3, import.total_rows
    assert_equal 1, import.processed_rows
    assert_equal 2, import.failed_rows
    assert_equal 2, import.row_errors.size

    blank_error = import.row_errors.find { |e| e["email"] == "" }
    assert_equal 2, blank_error["row"]
    assert_equal "Email is blank", blank_error["error"]

    dupe_error = import.row_errors.find { |e| e["email"] == "taken@example.com" }
    assert_equal 3, dupe_error["row"]
    assert_match(/Email has already been taken/, dupe_error["error"])
  end

  test "progress percent reflects completed rows" do
    import = UserImport.new(status: :processing, total_rows: 4, processed_rows: 1, failed_rows: 1)
    assert_equal 50, import.progress_percent

    import.total_rows = 0
    assert_equal 0, import.progress_percent
  end

  test "marks import failed when an unexpected error occurs mid-loop" do
    import = UserImport.new(status: :pending, total_rows: 0, processed_rows: 0, failed_rows: 0)
    import.file.attach(
      io: StringIO.new("full_name,email,password\nOk,boom@example.com,Password123\n"),
      filename: "boom.csv",
      content_type: "text/csv"
    )
    import.save!

    job = UserImportJob.new
    job.define_singleton_method(:read_rows) { |*| raise "boom" }
    assert_raises(RuntimeError) { job.perform(import) }

    import.reload
    assert_equal "failed", import.status
    refute_equal "processing", import.status
  end

  test "caps row_errors at 100 and flags truncation" do
    rows = (1..150).map { |i| ",blank-#{i}@example.com,Password123" }
    csv = "full_name,email,password\n#{rows.join("\n")}\n"

    import = UserImport.new(status: :pending, total_rows: 0, processed_rows: 0, failed_rows: 0)
    import.file.attach(io: StringIO.new(csv), filename: "many.csv", content_type: "text/csv")
    import.save!

    payloads = []
    UserImportChannel.define_singleton_method(:broadcast_to) { |_import, payload| payloads << payload }
    begin
      UserImportJob.new.perform(import)
    ensure
      UserImportChannel.singleton_class.send(:remove_method, :broadcast_to)
    end

    import.reload
    assert_equal 150, import.total_rows
    assert_equal 150, import.failed_rows
    assert_equal 100, import.row_errors.size
    assert_equal true, payloads.last[:errors_truncated]
  end
end
