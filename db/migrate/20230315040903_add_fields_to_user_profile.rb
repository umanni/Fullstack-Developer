class AddFieldsToUserProfile < ActiveRecord::Migration[7.1]
  def change
    add_column :user_profiles, :full_name, :string, null: false
    add_column :user_profiles, :avatar_image, :string, null: false
    add_column :user_profiles, :role, :integer, null: false
  end
end
