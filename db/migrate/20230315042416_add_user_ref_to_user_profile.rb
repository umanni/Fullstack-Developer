class AddUserRefToUserProfile < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_profiles, :user, null: false, foreign_key: true
  end
end
