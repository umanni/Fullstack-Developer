module AvatarUploadable
  extend ActiveSupport::Concern

  included do
    has_one_attached :avatar_image

    validates :avatar_image, content_type: {
      in: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'],
      message: 'must be a valid image format (JPEG, PNG, GIF, or WebP)'
    }, size: {
      less_than: 5.megabytes,
      message: 'must be less than 5MB'
    }, if: -> { avatar_image.attached? }
  end
end

