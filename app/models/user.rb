class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar_image do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 50, 50 ], saver: { quality: 75 }
    attachable.variant :medium, resize_to_limit: [ 500, 500 ], saver: { quality: 85 }
  end

  before_validation :generate_password, on: :create, unless: :password_present?

  validates :full_name, :email, :role, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email_present?
  validate :avatar_image_content_type

  enum :role, { admin: "admin", no_admin: "no_admin" }, default: :no_admin, validate: true

  private

  def avatar_image_content_type
    return unless avatar_image.attached?

    unless avatar_image.content_type.in?([ "image/png", "image/jpg", "image/jpeg", "image/avif" ])
      errors.add(:avatar_image, I18n.t("messages.errors.image.content_type"))
    end
  end

  def email_present?
    email.present?
  end

  def password_present?
    password.present?
  end

  def generate_password
    self.password = SecureRandom.alphanumeric(9)
  end
end
