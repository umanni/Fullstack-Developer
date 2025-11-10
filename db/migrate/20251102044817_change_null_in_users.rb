class ChangeNullInUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :full_name, false
    change_column_null :users, :email, false
  end
end
