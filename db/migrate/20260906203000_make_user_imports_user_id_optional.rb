class MakeUserImportsUserIdOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :user_imports, :user_id, true
  end
end
