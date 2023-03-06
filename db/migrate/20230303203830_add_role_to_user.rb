class AddRoleToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :role, :boolean, default: false
  end
end
