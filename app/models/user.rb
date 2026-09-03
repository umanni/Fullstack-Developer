class User < ApplicationRecord
  ROLES = { member: 0, admin: 1 }.freeze

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :created_imports, class_name: "UserImport", foreign_key: :created_by_id, inverse_of: :created_by, dependent: :destroy
  has_one_attached :avatar_image

  enum :role, ROLES, validate: true

  # Deterministic so uniqueness / authenticate_by / find_by(email) keep working.
  encrypts :email_address, deterministic: true

  normalizes :email_address, with: ->(email) { email.to_s.strip.downcase }
  normalizes :full_name, with: ->(name) { name.to_s.strip.squeeze(" ") }
  normalizes :avatar_url, with: ->(url) { url.to_s.strip.presence }

  validates :full_name, presence: true, length: { minimum: 2, maximum: 120 }
  validates :email_address, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :avatar_url, format: { with: /\Ahttps?:\/\/.+\z/i, allow_blank: true, message: "must be an http(s) URL" }
  validate :acceptable_avatar_image

  after_commit :broadcast_dashboard_stats, on: %i[create update destroy]

  def admin?
    role == "admin"
  end

  def member?
    role == "member"
  end

  def avatar_src
    return avatar_image if avatar_image.attached?
    return avatar_url if avatar_url.present?

    nil
  end

  def initials
    full_name.to_s.split.map { |part| part[0] }.first(2).join.upcase.presence || "?"
  end

  private

  def acceptable_avatar_image
    return unless avatar_image.attached?

    unless avatar_image.blob.content_type.in?(%w[image/png image/jpeg image/jpg image/webp image/gif])
      errors.add(:avatar_image, "must be a PNG, JPEG, WEBP, or GIF image")
    end

    if avatar_image.blob.byte_size > 5.megabytes
      errors.add(:avatar_image, "must be smaller than 5MB")
    end
  end

  def broadcast_dashboard_stats
    Users::DashboardBroadcaster.call
  end
end
