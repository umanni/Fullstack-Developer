class RemoveAvatarTempUrlFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :avatar_temp_url, :string
  end
end
