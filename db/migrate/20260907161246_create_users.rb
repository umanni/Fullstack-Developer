class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "user"

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
    add_check_constraint :users,
      "role IN ('user', 'admin')",
      name: "users_role_check"
  end
end
