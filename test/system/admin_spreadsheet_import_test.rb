require "application_system_test_case"

class AdminSpreadsheetImportTest < ApplicationSystemTestCase
  test "an administrator imports a CSV and sees completed progress" do
    sign_in_as_admin
    click_link "Imports"
    click_link "New import"

    perform_enqueued_jobs(only: Imports::ProcessJob) do
      attach_file "CSV or XLSX spreadsheet", file_fixture("valid_users.csv")
      click_button "Queue import"
      assert_text "Import queued for background processing."
    end

    assert_text(/\bcompleted\b/i)
    assert_text "100% complete"
    assert_text "2 of 2 rows processed"
    assert_text "Created"
  end

  test "an administrator imports an XLSX workbook" do
    sign_in_as_admin
    click_link "Imports"
    click_link "New import"

    perform_enqueued_jobs(only: Imports::ProcessJob) do
      attach_file "CSV or XLSX spreadsheet", file_fixture("valid_users.xlsx")
      click_button "Queue import"
      assert_text "Import queued for background processing."
    end

    assert_text(/\bcompleted\b/i)
    assert_text "2 of 2 rows processed"
  end

  private
    def sign_in_as_admin
      visit new_session_path
      fill_in "Email", with: users(:admin).email
      fill_in "Password", with: "SecurePass123!"
      click_button "Sign in"
    end
end
