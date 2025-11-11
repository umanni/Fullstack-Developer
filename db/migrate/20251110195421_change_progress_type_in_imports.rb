class ChangeProgressTypeInImports < ActiveRecord::Migration[8.0]
  def change
    change_column :imports, :progress, :float, default: 0.0, null: false
    change_column :imports, :total_rows, :integer, default: 0, null: false
    change_column :imports, :processed_rows, :integer, default: 0, null: false
  end
end
