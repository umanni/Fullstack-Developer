class CreateUserImportRows < ActiveRecord::Migration[8.1]
  def change
    create_table :user_import_rows do |t|
      t.references :user_import, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: { on_delete: :nullify }
      t.integer :row_number, null: false
      t.jsonb :payload, null: false, default: {}
      t.string :status, null: false, default: "pending"
      t.text :error_message

      t.timestamps
    end

    add_index :user_import_rows, [ :user_import_id, :row_number ], unique: true
    add_index :user_import_rows, [ :user_import_id, :status ]
    add_check_constraint :user_import_rows,
      "status IN ('pending', 'succeeded', 'failed')",
      name: "user_import_rows_status_check"
  end
end
