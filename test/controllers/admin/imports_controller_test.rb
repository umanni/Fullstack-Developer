require "test_helper"
require "tempfile"

module Admin
  class ImportsControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    setup do
      sign_in_as users(:admin)
    end

    test "queues import job" do
      file = Tempfile.new([ "users", ".csv" ])
      file.write("full_name,email\nJob User,job@import.test\n")
      file.rewind

      assert_enqueued_with(job: ProcessImportJob) do
        post admin_imports_url, params: {
          import: { spreadsheet: Rack::Test::UploadedFile.new(file.path, "text/csv", original_filename: "users.csv") }
        }
      end

      assert_redirected_to admin_import_url(Import.last)
    ensure
      file.close!
    end
  end
end
