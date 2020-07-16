class User < ApplicationRecord
  has_secure_password
  mount_base64_uploader :avatar_image, AvatarImageUploader
  validates_length_of :password,
                      maximum: 72,
                      minimum: 8,
                      allow_nil: true,
                      allow_blank: false
 
  validates_presence_of :full_name, :email
  validates :email, uniqueness: { scope: :email, message: "has registered!" }
end
