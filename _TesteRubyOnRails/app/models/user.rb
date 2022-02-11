class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # after_sign_in_path_for users_backoffice_welcome_index_path
  # after_sign_out_path_for site_welcome_index_path


  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      # users = find_or_create_by!(row["id"]) || new
      user_data = row[0].split(';')
      User.create({email: user_data[0], password: user_data[1], password_confirmation: user_data[2], full_name: user_data[3], avatar_image: user_data[4], admin: user_data[5] })
    end
  end
end
