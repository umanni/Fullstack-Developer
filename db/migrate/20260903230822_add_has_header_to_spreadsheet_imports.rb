class AddHasHeaderToSpreadsheetImports < ActiveRecord::Migration[8.1]
  def change
    add_column :spreadsheet_imports, :has_header, :boolean, default: true, null: false
  end
end
