class RemoveUserProfile < ActiveRecord::Migration[7.1]
  def change
     # remove the entire UserProfile table
    drop_table :user_profiles
  end
end
