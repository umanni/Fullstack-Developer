class CreateUserImports < ActiveRecord::Migration[8.0]
  def change
    create_table :user_imports do |t|
      t.integer :status
      t.integer :processed_count
      t.integer :total_count
      t.text :error_log

      t.timestamps
    end
  end
end
