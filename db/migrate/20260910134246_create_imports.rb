class CreateImports < ActiveRecord::Migration[8.1]
  def change
    create_table :imports do |t|
      t.references :user, null: false, foreign_key: true
      t.integer  :status,         null: false, default: 0
      t.integer  :total_rows,     null: false, default: 0
      t.integer  :processed_rows, null: false, default: 0
      t.integer  :created_count,  null: false, default: 0
      t.integer  :skipped_count,  null: false, default: 0
      t.integer  :failed_count,   null: false, default: 0
      t.jsonb    :error_report,   null: false, default: []
      t.string   :failure_reason
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end

    add_index :imports, %i[user_id created_at]
    add_index :imports, :status
  end
end
