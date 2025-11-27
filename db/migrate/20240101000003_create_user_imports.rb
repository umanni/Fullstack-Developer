class CreateUserImports < ActiveRecord::Migration[8.0]
  def change
    create_table :user_imports do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.integer :total_rows, default: 0
      t.integer :processed_rows, default: 0
      t.integer :success_count, default: 0
      t.integer :error_count, default: 0
      t.json :error_messages, default: []

      t.timestamps
    end

    add_index :user_imports, :status
    add_index :user_imports, :user_id
  end
end

