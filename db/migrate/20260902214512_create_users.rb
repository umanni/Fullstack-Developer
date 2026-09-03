class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0
      t.string :avatar_image_url

      t.timestamps
    end
    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email"
    add_check_constraint :users, "role IN (0, 1)", name: "users_role_check"
    add_check_constraint :users, "char_length(email) <= 254", name: "users_email_length_check"
    add_check_constraint :users, "char_length(full_name) BETWEEN 2 AND 100", name: "users_full_name_length_check"
  end
end
