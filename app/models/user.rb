class User < ApplicationRecord
  require 'open-uri'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attr_accessor :avatar_url

  enum role: [:no_admin, :admin]
  has_one_attached :avatar

  before_validation :attach_avatar_from_url!
  validates :full_name, presence: true
  validates :avatar, attached: true, content_type: ['image/jpg', 'image/jpeg', 'image/png'], size: { less_than: 10.megabytes }

  private
    def attach_avatar_from_url!
      if avatar_url.present?
        downloaded_image = open(avatar_url.to_s)
        self.avatar.attach(io: downloaded_image, filename: 'avatar')
      end
    end
end
