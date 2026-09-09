# Deleting an administrator who had ever run an import violated the foreign key
# and raised out of the controller as a 500. The import history is worth
# keeping when the account that asked for it is gone, so the reference becomes
# optional and the address is copied onto the row, where it survives.
class KeepImportsWhenTheirAdministratorIsRemoved < ActiveRecord::Migration[8.1]
  def up
    change_table :user_imports, bulk: true do |t|
      t.change_null :administrator_id, true
      t.string :administrator_email
    end

    execute <<~SQL.squish
      UPDATE user_imports
      SET administrator_email = users.email_address
      FROM users
      WHERE users.id = user_imports.administrator_id
        AND user_imports.administrator_email IS NULL
    SQL

    change_column_null :user_imports, :administrator_email, false
  end

  def down
    change_table :user_imports, bulk: true do |t|
      t.remove :administrator_email
      t.change_null :administrator_id, false
    end
  end
end
