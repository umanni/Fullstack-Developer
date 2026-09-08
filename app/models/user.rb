class User < ApplicationRecord
  AVATAR_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_AVATAR_BYTES = 5.megabytes

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :uploaded_user_imports,
    class_name: "UserImport",
    foreign_key: :uploaded_by_id,
    inverse_of: :uploaded_by,
    dependent: :destroy
  has_one_attached :avatar_image

  enum :role, { user: "user", admin: "admin" }, default: :user, validate: true

  normalizes :full_name, with: ->(name) { name.to_s.squish }
  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email,
    presence: true,
    length: { maximum: 254 },
    format: { with: URI::MailTo::EMAIL_REGEXP },
    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 12 }, if: -> { password.present? }
  validate :avatar_image_is_acceptable

  scope :alphabetical, -> { order(:full_name, :id) }

  # Separate blocks prevent Active Record from collapsing membership callbacks.
  after_create_commit { broadcast_statistics_later }
  after_update_commit(if: :saved_change_to_role?) { broadcast_statistics_later }
  after_destroy_commit { broadcast_statistics_later }

  def self.search(query)
    return all if query.blank?

    escaped_query = sanitize_sql_like(query.to_s.downcase.strip)
    where("LOWER(full_name) LIKE :query OR email LIKE :query", query: "%#{escaped_query}%")
  end

  private
    def avatar_image_is_acceptable
      return unless avatar_image.attached?

      unless avatar_image.blob.content_type.in?(AVATAR_CONTENT_TYPES)
        errors.add(:avatar_image, "must be a JPEG, PNG, or WebP image")
      end

      if avatar_image.blob.byte_size > MAX_AVATAR_BYTES
        errors.add(:avatar_image, "must be smaller than 5 MB")
      end
    end

    def broadcast_statistics_later
      return if Current.suppress_user_statistics_broadcasts

      UserStatisticsBroadcastJob.perform_later
    end
end
