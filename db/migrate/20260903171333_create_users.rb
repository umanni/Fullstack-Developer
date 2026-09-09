class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :full_name, null: false
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0
      t.string :avatar_url

      t.timestamps
    end

    # Uniqueness is enforced on the lowercased value so the database upholds the
    # same case-insensitive rule the model does, even for writes that skip
    # validation.
    add_index :users, "lower(email_address)", unique: true,
                                              name: "index_users_on_lower_email_address"
    add_index :users, :role

    # The enum only defines two roles; the constraint stops anything else from
    # reaching the column through a raw write.
    add_check_constraint :users, "role IN (0, 1)", name: "users_role_within_enum"
  end
end
