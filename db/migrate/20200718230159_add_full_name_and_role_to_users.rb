class AddFullNameAndRoleToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :full_name, :string
    add_column :users, :role, :integer, default: 0
  end
end
