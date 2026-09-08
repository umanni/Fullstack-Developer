class CreateUserImports < ActiveRecord::Migration[8.0]
  def change
    create_table :user_imports do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :total_rows, null: false, default: 0
      t.integer :processed_rows, null: false, default: 0
      t.integer :failed_rows, null: false, default: 0
      t.datetime :finished_at
      t.text :error_message

      t.timestamps
    end
    add_index :user_imports, :status
  end
end
