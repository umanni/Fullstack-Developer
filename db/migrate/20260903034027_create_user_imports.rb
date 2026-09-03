class CreateUserImports < ActiveRecord::Migration[8.1]
  def change
    create_table :user_imports do |t|
      t.integer :status, null: false, default: 0
      t.integer :total_rows, null: false, default: 0
      t.integer :processed_rows, null: false, default: 0
      t.integer :successful_rows, null: false, default: 0
      t.integer :failed_rows, null: false, default: 0
      t.text :error_message
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :user_imports, :status
  end
end
