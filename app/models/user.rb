class User < ApplicationRecord
  # No SVG: a stored SVG is a stored script, served from this origin.
  AVATAR_CONTENT_TYPES = %w[ image/png image/jpeg image/webp ].freeze
  AVATAR_MAX_SIZE = 2.megabytes

  DASHBOARD_STREAM = "dashboard".freeze

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :spreadsheet_imports, dependent: :destroy
  has_one_attached :avatar_image
  attr_accessor :remove_avatar_image

  # Deterministic so the column stays uniquely indexable and findable by exact value.
  # The cost is that LIKE on email is impossible; full_name stays in plaintext.
  encrypts :email, deterministic: true

  enum :role, { user: "user", admin: "admin" }, default: :user, validate: true

  # The macro calls `send` on the record for anything that does not respond to `call`,
  # so a bare `:dashboard` would go looking for User#dashboard.
  broadcasts_refreshes_to ->(_user) { DASHBOARD_STREAM }

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :full_name, with: ->(name) { name.strip }

  validates :full_name, presence: true, length: { maximum: 120 }
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :password, length: { minimum: 8 }, allow_nil: true
  validate :avatar_image_must_be_a_supported_image

  after_save :purge_avatar_image_if_requested
  # Enforced here because three routes can strip an admin: the role toggle, the admin
  # edit form, and a user deleting their own profile.
  validate :last_admin_keeps_the_role, on: :update
  # prepend so the check runs before the dependent: :destroy associations do their work.
  before_destroy :last_admin_is_not_deletable, prepend: true

  scope :ordered, -> { order(:full_name, :id) }
  scope :matching, ->(term) {
    term = term.to_s.strip
    if term.include?("@")
      where(email: term.downcase)
    else
      # sanitize_sql_like escapes with a backslash, which means nothing to LIKE unless
      # the clause names it: without ESCAPE, a search for "100%" looks for a literal
      # backslash and finds nobody.
      where("full_name LIKE ? ESCAPE '\\'", "%#{sanitize_sql_like(term)}%")
    end
  }

  def initials
    full_name.to_s.split.first(2).filter_map { |part| part[0] }.join.upcase
  end

  private
    # Check-then-act. Safe only because the SQLite adapter opens with BEGIN IMMEDIATE;
    # PostgreSQL would need a lock.
    def another_admin_exists?
      self.class.admin.where.not(id: id).exists?
    end

    def last_admin_keeps_the_role
      return unless role_changed?(from: "admin")
      return if another_admin_exists?

      errors.add(:role, "cannot change: this is the only admin left")
    end

    def last_admin_is_not_deletable
      # An unsaved change to the role must not decide whether the record can go.
      return unless role_in_database == "admin"
      return if another_admin_exists?

      errors.add(:base, "The only admin cannot be deleted.")
      throw :abort
    end

    def purge_avatar_image_if_requested
      avatar_image.purge if remove_avatar_image == "1" && avatar_image.attached?
    end

    def avatar_image_must_be_a_supported_image
      return unless avatar_image.attached?

      errors.add(:avatar_image, "is empty") if avatar_image.byte_size.zero?
      if avatar_image.byte_size > AVATAR_MAX_SIZE
        errors.add(:avatar_image, "must be under #{AVATAR_MAX_SIZE / 1.megabyte} MB")
      end
      return if uploaded_avatar_type.in?(AVATAR_CONTENT_TYPES)

      errors.add(:avatar_image, "must be a PNG, JPEG or WebP image")
    end

    # Read from the bytes, not from the name. Marcel trusts the extension when that is
    # all it is given, so a .txt renamed .png arrives declaring itself an image.
    def uploaded_avatar_type
      io = avatar_upload_io
      return avatar_image.content_type unless io

      Marcel::MimeType.for(io)
    ensure
      # Sniffing leaves the stream at EOF, and it belongs to whoever handed it over.
      io.rewind if io.respond_to?(:rewind)
    end

    def avatar_upload_io
      attachable = attachment_changes["avatar_image"]&.attachable
      return attachable[:io] if attachable.is_a?(Hash)

      attachable if attachable.respond_to?(:read)
    end
end
