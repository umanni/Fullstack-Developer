class User < ApplicationRecord
  AVATAR_CONTENT_TYPES = %w[image/png image/jpeg image/webp].freeze
  AVATAR_MAX_BYTES = 5.megabytes
  DASHBOARD_COUNTS_CACHE_KEY = "admin_dashboard_counts"

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one_attached :avatar

  enum :role, { no_admin: 0, admin: 1 }

  attribute :avatar_url, :string
  attr_accessor :skip_dashboard_broadcast

  normalizes :email, with: -> { it.strip.downcase }

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_blank: true
  validate :avatar_must_be_a_supported_image, if: -> { avatar.attached? }
  validate :avatar_url_must_be_http, if: -> { avatar_url.present? }

  after_commit :enqueue_avatar_download, if: -> { avatar_url.present? }
  after_commit :broadcast_dashboard_counts, if: -> { !skip_dashboard_broadcast && (destroyed? || previously_new_record? || saved_change_to_role?) }

  def self.dashboard_counts
    Rails.cache.fetch(DASHBOARD_COUNTS_CACHE_KEY) { { total_users: count, users_by_role: group(:role).count } }
  end

  # Used by SpreadsheetImportJob to broadcast once after a bulk import instead of
  # once per created user (each of which skips its own broadcast via
  # skip_dashboard_broadcast).
  def self.broadcast_dashboard_counts!
    Rails.cache.delete(DASHBOARD_COUNTS_CACHE_KEY)
    counts = dashboard_counts

    Turbo::StreamsChannel.broadcast_replace_to(
      "admin_dashboard",
      target: "dashboard_counts",
      partial: "admin/dashboards/counts",
      locals: counts
    )
  end

  private
    def avatar_must_be_a_supported_image
      errors.add(:avatar, "deve ser uma imagem PNG, JPEG ou WEBP") unless avatar.content_type.in?(AVATAR_CONTENT_TYPES)
      errors.add(:avatar, "é muito grande (máx #{AVATAR_MAX_BYTES / 1.megabyte}MB)") if avatar.byte_size > AVATAR_MAX_BYTES
    end

    def avatar_url_must_be_http
      uri = URI.parse(avatar_url)
      errors.add(:avatar_url, "deve ser uma URL http(s) válida") unless uri.is_a?(URI::HTTP) && uri.host.present?
    rescue URI::InvalidURIError
      errors.add(:avatar_url, "deve ser uma URL http(s) válida")
    end

    def enqueue_avatar_download
      AvatarDownloadJob.perform_later(id, avatar_url)
    end

    def broadcast_dashboard_counts
      self.class.broadcast_dashboard_counts!
    end
end
