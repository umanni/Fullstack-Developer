# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  avatar_url      :string
#  email           :string           not null
#  full_name       :string           not null
#  password_digest :string           not null
#  role            :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one_attached :avatar_image

  enum :role, { user: 0, admin: 1 }, default: :user

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :avatar_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?
  validate :password_complexity, if: :password_digest_changed?
  validate :avatar_image_size

  def avatar_display
    avatar_image.attached? ? avatar_image : avatar_url
  end

  after_commit :broadcast_dashboard_counts, on: %i[ create update destroy ]

  private
    def password_complexity
      return if password.blank?
      errors.add(:password, "must include at least one uppercase letter") unless password.match?(/[A-Z]/)
      errors.add(:password, "must include at least one lowercase letter") unless password.match?(/[a-z]/)
      errors.add(:password, "must include at least one digit") unless password.match?(/\d/)
    end

    def avatar_image_size
      return unless avatar_image.attached?
      if avatar_image.blob.byte_size > MAX_AVATAR_UPLOAD_SIZE
        avatar_image.purge
        errors.add(:avatar_image, "is too large (maximum is #{MAX_AVATAR_UPLOAD_SIZE / 1.megabyte}MB)")
      end
    end

    def broadcast_dashboard_counts
      ActionCable.server.broadcast(
        "dashboard",
        { total_users: User.count, users_by_role: User.group(:role).count }
      )
    rescue StandardError => e
      Rails.logger.error("[User] broadcast_dashboard_counts failed: #{e.class}: #{e.message}")
    end
end
