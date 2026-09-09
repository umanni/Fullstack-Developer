require "test_helper"

class AdminImportTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @admin = User.create!(full_name: "Admin", email: "import-admin@example.com", password: "password123", password_confirmation: "password123", role: :admin)
    sign_in_as(@admin)
  end

  test "upload csv enqueues job and creates users with progress" do
    csv = "full_name,email,password\nImported One,imp1@example.com,password123\nImported Two,imp2@example.com,password123\n"
    file = Tempfile.new([ "users", ".csv" ])
    file.write(csv)
    file.rewind

    assert_difference("User.count", 2) do
      perform_enqueued_jobs do
        post admin_user_imports_path, params: { user_import: { file: Rack::Test::UploadedFile.new(file.path, "text/csv") } }
      end
    end

    import = UserImport.last
    assert_equal "completed", import.status
    assert_equal 2, import.total_rows
    assert_equal 2, import.processed_rows
    get admin_user_import_path(import)
    assert_response :success
    assert_match "completed", response.body
  end

  test "upload xlsx creates users" do
    require "rubyXL"
    wb = RubyXL::Workbook.new
    ws = wb[0]
    ws.add_cell(0, 0, "full_name"); ws.add_cell(0, 1, "email"); ws.add_cell(0, 2, "password")
    ws.add_cell(1, 0, "X One"); ws.add_cell(1, 1, "x1@example.com"); ws.add_cell(1, 2, "password123")
    file = Tempfile.new([ "users", ".xlsx" ])
    wb.write(file.path)

    assert_difference("User.count", 1) do
      perform_enqueued_jobs do
        post admin_user_imports_path, params: { user_import: { file: Rack::Test::UploadedFile.new(file.path, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") } }
      end
    end
    assert_equal "completed", UserImport.last.status
  end

  test "non-admin cannot import" do
    user = User.create!(full_name: "U", email: "nimp@example.com", password: "password123", password_confirmation: "password123")
    sign_in_as(user)
    get admin_user_imports_path
    assert_redirected_to root_path
  end
end
