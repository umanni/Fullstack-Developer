class AddEncryptedColumnsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :encrypted_email, :string
    add_column :users, :encrypted_full_name, :string
  end
end
