require "application_system_test_case"

class SpreadsheetImportFlowTest < ApplicationSystemTestCase
  setup { sign_in_as users(:admin) }

  test "uploads a spreadsheet and watches it finish without reloading" do
    visit new_admin_spreadsheet_import_path

    attach_file "Spreadsheet", file_fixture("users.csv")
    click_on "Start import"

    assert_text "Pending"
    assert_selector "[role=progressbar][aria-valuenow='0']"

    assert_difference -> { User.count }, 3 do
      perform_enqueued_jobs
    end

    assert_text "Completed"
    assert_selector "[role=progressbar][aria-valuenow='100']"
    assert_text "5 of 5 rows"
    assert_equal 100, rendered_progress_percentage
  end

  test "draws the bar at the width it reports" do
    import = users(:admin).spreadsheet_imports.create!(
      file: { io: file_fixture("users.csv").open, filename: "users.csv" }
    )
    import.update!(status: :processing, total_rows: 10, processed_rows: 3)

    visit admin_spreadsheet_import_path(import)

    assert_selector "[role=progressbar][aria-valuenow='30']"
    assert_equal 30, rendered_progress_percentage
  end

  test "reports the rows it could not import, by line and reason" do
    visit new_admin_spreadsheet_import_path
    attach_file "Spreadsheet", file_fixture("users.csv")
    click_on "Start import"

    assert_text "Pending"

    perform_enqueued_jobs

    assert_text "Rows that could not be imported"
    assert_text "Line 5"
    assert_text "Full name can't be blank"
    assert_text "Line 6"
    assert_text "Email has already been taken"
  end

  test "refuses a file that is not a spreadsheet" do
    visit new_admin_spreadsheet_import_path

    attach_file "Spreadsheet", file_fixture("not-an-image.txt")
    click_on "Start import"

    assert_text "File must be a .csv or .xlsx file"
  end

  test "lists finished imports" do
    visit new_admin_spreadsheet_import_path
    attach_file "Spreadsheet", file_fixture("users.xlsx")
    click_on "Start import"

    assert_text "Pending"

    perform_enqueued_jobs

    assert_text "Completed"

    click_on "All imports"

    assert_text "users.xlsx"
    assert_text "3 imported, 2 rejected"
  end

  private
    def rendered_progress_percentage
      page.evaluate_script(<<~JS).round
        (() => {
          const fill = document.querySelector("[role=progressbar] > div");
          return fill.getBoundingClientRect().width /
                 fill.parentElement.getBoundingClientRect().width * 100;
        })()
      JS
    end
end
