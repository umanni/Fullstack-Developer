class ChangeRoleToIntegerInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :role, :integer, default: 0, using: 'role::integer'
  end
end
