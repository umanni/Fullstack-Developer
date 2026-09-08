class CreateUserImports < ActiveRecord::Migration[8.1]
  def change
    create_table :user_imports do |t|
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "pending"
      t.integer :total_rows, null: false, default: 0
      t.integer :processed_rows, null: false, default: 0
      t.integer :successful_rows, null: false, default: 0
      t.integer :failed_rows, null: false, default: 0
      t.text :failure_message
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :user_imports, :status
    add_check_constraint :user_imports,
      "status IN ('pending', 'processing', 'completed', 'completed_with_errors', 'failed')",
      name: "user_imports_status_check"
    add_check_constraint :user_imports,
      "total_rows >= 0 AND processed_rows >= 0 AND successful_rows >= 0 AND failed_rows >= 0",
      name: "user_imports_non_negative_counters_check"
    add_check_constraint :user_imports,
      "processed_rows = successful_rows + failed_rows AND processed_rows <= total_rows",
      name: "user_imports_consistent_counters_check"
  end
end
