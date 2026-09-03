require "test_helper"

module Admin
  class ImportsControllerExtraTest < ActionDispatch::IntegrationTest
    setup { sign_in_as users(:admin) }

    test "shows import details" do
      import = UserImport.new(created_by: users(:admin), status: :completed, total_rows: 1, processed_rows: 1, successful_rows: 1)
      import.spreadsheet.attach(io: StringIO.new("full_name,email\nA,a@example.com\n"), filename: "users.csv", content_type: "text/csv")
      import.save!

      get admin_import_url(import)
      assert_response :success
      assert_match "##{import.id}", response.body
    end

    test "invalid upload re-renders index" do
      post admin_imports_url, params: { user_import: { spreadsheet: "" } }
      assert_response :unprocessable_entity
    end
  end
end
