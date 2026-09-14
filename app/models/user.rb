class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :imports, dependent: :destroy
  has_one_attached :avatar_image

  enum :role, { member: 0, admin: 1 }, default: :member, validate: true

  encrypts :email_address, deterministic: true

  normalizes :email_address, with: ->(value) { value.to_s.strip.downcase }
  normalizes :full_name,     with: ->(value) { value.to_s.squish }

  validates :full_name, presence: true, length: { in: 2..120 }
  validates :email_address,
            presence: true,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :avatar_url,
            format: { with: %r{\Ahttps://\S+\z} },
            allow_blank: true
  validates :avatar_image,
            content_type: %w[image/png image/jpeg image/webp],
            size: { less_than: 5.megabytes },
            if: -> { avatar_image.attached? }

  before_destroy :ensure_not_last_admin, prepend: true
  validate :admin_headcount_preserved, on: :update

  after_commit :broadcast_dashboard_stats, on: %i[create destroy],
               unless: -> { DashboardBroadcasts.suppressed? }
  # Block form on purpose: `after_commit` dedupes by filter, so the same symbol
  # registered twice would drop the declaration above.
  after_commit(on: :update, if: -> { saved_change_to_role? && !DashboardBroadcasts.suppressed? }) do
    broadcast_dashboard_stats
  end

  def avatar_source
    return avatar_image if avatar_image.attached?
    avatar_url.presence
  end

  private

  def broadcast_dashboard_stats
    Dashboard::Broadcaster.call
  end

  def ensure_not_last_admin
    return unless admin? && User.admin.count <= 1

    errors.add(:base, "Cannot remove the last administrator")
    throw :abort
  end

  def admin_headcount_preserved
    return unless role_previously_was_admin_and_now_member?
    return if User.admin.where.not(id: id).exists?

    errors.add(:role, "cannot change: at least one administrator is required")
  end

  def role_previously_was_admin_and_now_member?
    role_changed? && role_was == "admin" && member?
  end
end
