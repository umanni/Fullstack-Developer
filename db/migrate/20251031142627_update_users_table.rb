class UpdateUsersTable < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :email, :string
    remove_column :users, :full_name, :string
  end
end
