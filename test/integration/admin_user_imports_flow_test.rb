require "test_helper"

class AdminUserImportsFlowTest < ActionDispatch::IntegrationTest
  setup do
    post session_path, params: { email_address: users(:one).email_address, password: "Password123!" }
  end

  test "index lists the import history through the presenter" do
    get admin_user_imports_path

    assert_inertia_response
    assert_inertia_component "Admin/UserImports/Index"
    assert_inertia_props { |props| props[:pagination][:count] == UserImport.count }
  end

  test "new page shows the upload form plus recent history" do
    get new_admin_user_import_path

    assert_inertia_component "Admin/UserImports/New"
    assert_inertia_props { |props| props[:urls][:submit_url] == admin_user_imports_path }
  end

  test "uploading a csv enqueues the job and processes rows to completion" do
    assert_enqueued_with(job: UserImports::Job) do
      post admin_user_imports_path, params: { file: fixture_file_upload("users.csv", "text/csv") }
    end

    user_import = UserImport.last
    assert_redirected_to admin_user_import_path(user_import)
    assert_predicate user_import, :pending?
    assert_not_nil user_import.file.attached?

    perform_enqueued_jobs

    user_import.reload
    assert_predicate user_import, :completed?
    assert_equal 2, user_import.total_rows
    assert_equal 2, user_import.processed_rows
    assert_equal 0, user_import.failed_rows
    assert_equal 2, User.where(email_address: %w[alice.import@iam.test bob.import@iam.test]).count
  end

  test "show renders details used by the progress bar" do
    user_import = UserImport.last

    get admin_user_import_path(user_import)

    assert_inertia_component "Admin/UserImports/Show"
    assert_inertia_props do |props|
      props[:import][:id] == user_import.id && props[:import].key?(:progress)
    end
  end

  test "unsupported files re-render new with a model error" do
    post admin_user_imports_path, params: { file: fixture_file_upload("avatar.png", "image/png") }

    assert_inertia_component "Admin/UserImports/New"
    assert_inertia_props { |props| props.dig(:errors, :file).present? }
  end

  test "non-admin users cannot reach the imports area" do
    delete session_path
    post session_path, params: { email_address: users(:two).email_address, password: "Password123!" }

    get admin_user_imports_path
    assert_redirected_to root_path
  end
end
