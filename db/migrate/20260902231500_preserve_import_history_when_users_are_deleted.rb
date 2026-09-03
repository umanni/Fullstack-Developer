class PreserveImportHistoryWhenUsersAreDeleted < ActiveRecord::Migration[8.1]
  def up
    change_column_null :user_imports, :created_by_id, true

    replace_user_foreign_key(:user_imports, :created_by_id, on_delete: :nullify)
    replace_user_foreign_key(:user_import_rows, :user_id, on_delete: :nullify)
  end

  def down
    null_references = select_value(<<~SQL.squish)
      SELECT EXISTS (
        SELECT 1 FROM user_imports WHERE created_by_id IS NULL
        UNION ALL
        SELECT 1 FROM user_import_rows WHERE user_id IS NULL AND status = 1
      )
    SQL
    if null_references
      raise ActiveRecord::IrreversibleMigration, "anonymized import references cannot recover their original users"
    end

    replace_user_foreign_key(:user_imports, :created_by_id)
    replace_user_foreign_key(:user_import_rows, :user_id)
    change_column_null :user_imports, :created_by_id, false
  end

  private
    def replace_user_foreign_key(table, column, **options)
      remove_foreign_key(table, :users, column: column)
      add_foreign_key(table, :users, column: column, **options)
    end
end
