class AddAvatarTempUrlToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :avatar_temp_url, :string
  end
end
