class AddFailureReasonToSpreadsheetImports < ActiveRecord::Migration[8.1]
  def change
    add_column :spreadsheet_imports, :failure_reason, :string
  end
end
