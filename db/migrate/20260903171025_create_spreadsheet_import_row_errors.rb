class CreateSpreadsheetImportRowErrors < ActiveRecord::Migration[8.1]
  def change
    create_table :spreadsheet_import_row_errors do |t|
      t.references :spreadsheet_import, null: false, foreign_key: true
      t.integer :row_number, null: false
      t.string :message, null: false
      t.text :raw_data

      t.timestamps
    end
  end
end
