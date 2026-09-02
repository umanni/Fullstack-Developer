class CreateUserImports < ActiveRecord::Migration[8.1]
  def change
    create_table :user_imports do |t|
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0
      t.integer :total_rows, null: false, default: 0
      t.integer :processed_rows, null: false, default: 0
      t.integer :succeeded_rows, null: false, default: 0
      t.integer :failed_rows, null: false, default: 0
      t.datetime :started_at
      t.datetime :finished_at
      t.text :failure_message

      t.timestamps
    end

    add_check_constraint :user_imports, "status IN (0, 1, 2, 3, 4)", name: "user_imports_status_check"
    add_check_constraint :user_imports,
      "total_rows >= 0 AND processed_rows >= 0 AND succeeded_rows >= 0 AND failed_rows >= 0",
      name: "user_imports_counters_non_negative_check"
  end
end
