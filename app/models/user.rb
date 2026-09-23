class User < ApplicationRecord
  belongs_to :user_role
  has_many :sessions, dependent: :destroy
  has_many :imports, dependent: :destroy
  has_one_attached :avatar_image

  has_secure_password
  generates_token_for :password_reset, expires_in: 15.minutes

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validate :avatar_url_must_be_http_url, if: -> { avatar_url.present? }

  after_commit :broadcast_dashboard_stats, on: %i[create update destroy]

  scope :admins, -> { joins(:user_role).where(user_roles: { is_admin: true }) }
  scope :non_admins, -> { joins(:user_role).where(user_roles: { is_admin: false }) }

  def admin?
    user_role&.is_admin?
  end

  def avatar_display_url
    if avatar_image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(avatar_image, only_path: true)
    elsif avatar_url.present?
      avatar_url
    end
  end

  def toggle_role!
    target = admin? ? UserRole.non_admin : UserRole.admin
    update!(user_role: target)
  end

  def self.dashboard_stats
    {
      total: count,
      admins: admins.count,
      non_admins: non_admins.count
    }
  end

  private

  def avatar_url_must_be_http_url
    uri = URI.parse(avatar_url)
    errors.add(:avatar_url, :invalid_url) unless uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    errors.add(:avatar_url, :invalid_url)
  end

  def broadcast_dashboard_stats
    DashboardChannel.broadcast_stats
  end
end
