class User < ApplicationRecord
  AVATAR_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_AVATAR_SIZE = 5.megabytes
  NORMALIZE_EMAIL = ->(value) { value.to_s.strip.downcase }.freeze

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :created_imports, class_name: "UserImport", foreign_key: :created_by_id,
    inverse_of: :created_by, dependent: :nullify
  has_many :import_rows, class_name: "UserImportRow", dependent: :nullify
  has_one_attached :avatar_image

  enum :role, { user: 0, admin: 1 }, default: :user, validate: true

  normalizes :email, with: NORMALIZE_EMAIL
  normalizes :full_name, with: ->(name) { name.strip.gsub(/\s+/, " ") }
  normalizes :avatar_image_url, with: ->(url) { url.strip.presence }

  validates :full_name, presence: true, length: { in: 2..100 }
  validates :email, presence: true, length: { maximum: 254 },
    format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 12 }, allow_nil: true
  validate :avatar_source_present
  validate :avatar_upload_is_safe
  validate :remote_avatar_is_safe

  def initials
    full_name.split.filter_map { |part| part[0] }.first(2).join.upcase
  end

  def self.normalized_email(value)
    NORMALIZE_EMAIL.call(value)
  end

  private
    def avatar_source_present
      return if avatar_image.attached? || avatar_image_url.present?

      errors.add(:avatar_image, "or a remote avatar URL must be provided")
    end

    def avatar_upload_is_safe
      return unless avatar_image.attached?

      blob = avatar_image.blob
      errors.add(:avatar_image, "must be a JPEG, PNG, or WebP image") unless AVATAR_CONTENT_TYPES.include?(blob.content_type)
      errors.add(:avatar_image, "must be smaller than 5 MB") if blob.byte_size > MAX_AVATAR_SIZE
    end

    def remote_avatar_is_safe
      return if avatar_image_url.blank?

      uri = URI.parse(avatar_image_url)
      return if uri.is_a?(URI::HTTPS) && uri.host.present? && uri.userinfo.blank?

      errors.add(:avatar_image_url, "must be a valid HTTPS URL without embedded credentials")
    rescue URI::InvalidURIError
      errors.add(:avatar_image_url, "must be a valid HTTPS URL")
    end
end
