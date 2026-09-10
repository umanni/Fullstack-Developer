# frozen_string_literal: true

class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.bigint :user_id
      t.string :action, null: false
      t.string :auditable_type
      t.bigint :auditable_id
      t.jsonb :metadata, default: {}
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end

    add_index :audit_logs, :user_id
    add_index :audit_logs, [ :auditable_type, :auditable_id ]
    add_index :audit_logs, :created_at
    add_foreign_key :audit_logs, :users
  end
end
