class AddCountersToImports < ActiveRecord::Migration[8.0]
  def change
    add_column :imports, :successful_rows, :integer, default: 0, null: false
    add_column :imports, :failed_rows, :integer, default: 0, null: false
  end
end
