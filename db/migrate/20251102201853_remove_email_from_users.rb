class RemoveEmailFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :email, :string
  end
end
