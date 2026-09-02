class CreateUserImportRows < ActiveRecord::Migration[8.1]
  def change
    create_table :user_import_rows do |t|
      t.references :user_import, null: false, foreign_key: true
      t.integer :row_number, null: false
      t.integer :status, null: false, default: 0
      t.jsonb :payload, null: false, default: {}
      t.text :error_message
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end

    add_index :user_import_rows, [ :user_import_id, :row_number ], unique: true
    add_check_constraint :user_import_rows, "status IN (0, 1, 2)", name: "user_import_rows_status_check"
    add_check_constraint :user_import_rows, "row_number >= 2", name: "user_import_rows_row_number_check"
  end
end
