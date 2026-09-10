# frozen_string_literal: true

class FixAuditLogsForeignKey < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :audit_logs, :users
    add_foreign_key :audit_logs, :users, on_delete: :nullify
  end
end
