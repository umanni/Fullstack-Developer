class AddFieldsToUserProfile < ActiveRecord::Migration[7.1]
  def change
    add_column :user_profiles, :full_name, :string
    add_column :user_profiles, :avatar_image, :string
    add_column :user_profiles, :role, :integer
  end
end
