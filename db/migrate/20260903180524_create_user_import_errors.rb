class CreateUserImportErrors < ActiveRecord::Migration[8.1]
  def change
    create_table :user_import_errors do |t|
      t.references :user_import, null: false, foreign_key: true
      t.integer :row_number, null: false

      # Kept as given, not normalised: the report has to show the operator what
      # was actually in the file so they can find and fix the row.
      t.string :email_address
      t.string :messages, array: true, null: false, default: []

      t.timestamps
    end

    add_index :user_import_errors, %i[user_import_id row_number]
    add_check_constraint :user_import_errors, "row_number > 0", name: "user_import_errors_row_number_positive"
  end
end
