class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  validates :full_name, presence: true

  validate :acceptable_avatar

  private

  def acceptable_avatar
    return unless avatar.attached?

    valid_types = [ "image/png", "image/jpg", "image/jpeg" ]
    unless avatar.content_type.in?(valid_types)
      errors.add(:avatar, "must be a PNG, JPG, or JPEG")
    end

    if avatar.byte_size > 5.megabytes
      errors.add(:avatar, "maximum size allowed is 5MB")
    end
  end
end
