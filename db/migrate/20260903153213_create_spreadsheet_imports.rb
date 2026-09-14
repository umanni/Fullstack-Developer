class CreateSpreadsheetImports < ActiveRecord::Migration[8.1]
  def change
    create_table :spreadsheet_imports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.integer :total_rows, null: false, default: 0
      t.integer :processed_rows, null: false, default: 0
      t.integer :failed_rows, null: false, default: 0
      # One entry per rejected row: the row number and why. Kept on the import so the
      # admin can fix the file, rather than only in the log.
      t.json :row_errors, null: false, default: []

      t.timestamps
    end

    add_check_constraint :spreadsheet_imports,
                         "status IN ('pending', 'processing', 'completed', 'failed')",
                         name: "spreadsheet_imports_status_check"
  end
end
