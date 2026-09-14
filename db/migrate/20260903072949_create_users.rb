class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "user"

      t.timestamps
    end

    # The email column stores ciphertext (deterministic encryption), so the unique
    # index compares ciphertext. That works precisely because the encryption is
    # deterministic; a randomised scheme would silently allow duplicates.
    add_index :users, :email, unique: true

    # The enum guards this in Ruby. The constraint guards it against console
    # sessions, data migrations and anything else that bypasses the model.
    add_check_constraint :users, "role IN ('user', 'admin')", name: "users_role_check"
  end
end
