class AddFileNameToUserImports < ActiveRecord::Migration[8.1]
  def change
    add_column :user_imports, :file_name, :string
  end
end
