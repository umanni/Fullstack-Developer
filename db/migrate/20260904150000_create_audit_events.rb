# Who changed whom, and when. A system whose whole purpose is administering
# accounts should be able to answer that question, and it cannot be answered
# from the users table: the row that would tell you is the one that changed.
class CreateAuditEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_events do |t|
      # Both sides are nullable and nullified, because an audit trail that
      # disappears when an account does is not an audit trail. The addresses
      # are copied so the record still reads after either is gone.
      t.references :actor, foreign_key: { to_table: :users, on_delete: :nullify }
      t.references :subject, foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :actor_email, null: false
      t.string :subject_email, null: false

      t.integer :action, null: false
      t.jsonb :details, null: false, default: {}

      # No updated_at: an audit row is written once and never edited.
      t.datetime :created_at, null: false
    end

    add_index :audit_events, :created_at
    add_index :audit_events, :action
    add_check_constraint :audit_events, "action BETWEEN 0 AND 5", name: "audit_events_action_within_enum"
  end
end
