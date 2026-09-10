class AddRowErrorsToUserImports < ActiveRecord::Migration[8.1]
  def change
    add_column :user_imports, :row_errors, :jsonb, null: false, default: []
  end
end
