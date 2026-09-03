require "test_helper"
require "tempfile"

module Admin
  class ImportsControllerTest < ActionDispatch::IntegrationTest
    setup { sign_in_as users(:admin) }

    test "admin can upload spreadsheet and enqueue job" do
      file = Tempfile.new([ "users", ".csv" ])
      file.write("full_name,email,password\nImport Me,importme@example.com,password123\n")
      file.rewind

      assert_enqueued_with(job: ProcessUserImportJob) do
        assert_difference("UserImport.count", 1) do
          post admin_imports_url, params: {
            user_import: {
              spreadsheet: Rack::Test::UploadedFile.new(file.path, "text/csv", original_filename: "users.csv")
            }
          }
        end
      end

      assert_redirected_to admin_imports_url
      file.close!
    end
  end
end
