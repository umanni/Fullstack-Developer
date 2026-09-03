class CreateUserImports < ActiveRecord::Migration[8.1]
  def change
    create_table :user_imports do |t|
      t.references :administrator, null: false, foreign_key: { to_table: :users }

      t.integer :status, null: false, default: 0

      # Counters rather than derived queries: the import reports progress while
      # it is still running, when the rows it has not reached yet do not exist
      # anywhere to be counted.
      t.integer :total_rows, null: false, default: 0
      t.integer :processed_rows, null: false, default: 0
      t.integer :created_users, null: false, default: 0
      t.integer :rejected_rows, null: false, default: 0

      # Set only when the whole import failed, as opposed to individual rows.
      t.text :failure_reason

      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :user_imports, :status
    add_index :user_imports, :created_at

    add_check_constraint :user_imports, "status BETWEEN 0 AND 4", name: "user_imports_status_within_enum"
    add_check_constraint :user_imports,
                         "total_rows >= 0 AND processed_rows >= 0 AND created_users >= 0 AND rejected_rows >= 0",
                         name: "user_imports_counters_not_negative"
  end
end
