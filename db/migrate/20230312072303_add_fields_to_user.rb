class AddFieldsToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :full_name, :string
    add_column :users, :avatar_image, :string
    add_column :users, :role, :integer, default: 2
  end
end
