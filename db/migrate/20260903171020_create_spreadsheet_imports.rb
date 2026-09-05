class CreateSpreadsheetImports < ActiveRecord::Migration[8.1]
  def change
    create_table :spreadsheet_imports do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :total_rows, null: false, default: 0
      t.integer :processed_rows, null: false, default: 0

      t.timestamps
    end
  end
end
