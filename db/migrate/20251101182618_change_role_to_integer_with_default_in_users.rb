class ChangeRoleToIntegerWithDefaultInUsers < ActiveRecord::Migration[7.1]
  def up
    # cria coluna temporária
    add_column :users, :role_tmp, :integer, default: 0

    # copia os valores convertendo
    User.reset_column_information
    User.find_each do |u|
      u.update_column(:role_tmp, u.role == 'admin' ? 1 : 0)
    end

    # remove coluna antiga e renomeia a temporária
    remove_column :users, :role
    rename_column :users, :role_tmp, :role
  end

  def down
    add_column :users, :role_tmp, :string, default: 'user'
    User.reset_column_information
    User.find_each do |u|
      u.update_column(:role_tmp, u.role == 1 ? 'admin' : 'user')
    end
    remove_column :users, :role
    rename_column :users, :role_tmp, :role
  end
end
