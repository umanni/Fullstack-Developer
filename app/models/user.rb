class User < ApplicationRecord
  MAX_FULL_NAME_LENGTH = 120

  # The locales the interface is actually translated into. Keeping the list on
  # the model means the validation, the check constraint and the language
  # picker all read from one place.
  SUPPORTED_LOCALES = %w[en pt-BR es].freeze

  # Avatars are checked against what the bytes actually are, not what the
  # upload claims they are.
  AVATAR_CONTENT_TYPES = %w[image/png image/jpeg image/webp image/gif].freeze
  MAX_AVATAR_BYTES = 2.megabytes

  # Only ordinary web URLs. javascript:, data: and file: are all valid URIs and
  # none of them belong in an img src.
  AVATAR_URL_SCHEMES = %w[http https].freeze

  # An invitation lasts a week, not the fifteen minutes has_secure_password
  # gives a password reset: somebody imported at two in the morning should not
  # find a dead link. Like the reset token, it is derived from the password
  # salt, so it stops working the moment a password is set.
  INVITATION_VALID_FOR = 7.days

  has_secure_password
  generates_token_for :invitation, expires_in: INVITATION_VALID_FOR do
    password_salt&.last(10)
  end
  has_many :sessions, dependent: :destroy
  # Nullified rather than destroyed: removing an administrator must not erase
  # the record of the imports they ran. Without this the foreign key raised.
  has_many :user_imports, foreign_key: :administrator_id, inverse_of: :administrator, dependent: :nullify
  has_one_attached :avatar

  # Two roles, explicitly numbered so the values are stable in the database and
  # match the check constraint. `validate: true` turns an unknown role into a
  # validation error instead of an ArgumentError raised from the setter.
  enum :role, { user: 0, admin: 1 }, default: :user, validate: true

  normalizes :email_address, with: ->(value) { value.strip.downcase }
  normalizes :full_name, with: ->(value) { value.strip.gsub(/\s+/, " ") }

  validates :full_name, presence: true, length: { maximum: MAX_FULL_NAME_LENGTH }
  validates :email_address,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }
  validates :locale, inclusion: { in: SUPPORTED_LOCALES }

  validate :acceptable_avatar, if: -> { attachment_changes.key?("avatar") }
  validate :avatar_url_is_an_ordinary_web_url, if: -> { avatar_url.present? }

  # The last administrator may not be removed or demoted. This lives on the
  # model rather than in a controller so it holds for every path into the
  # data: the admin screens, the console, a seed, a future import.
  before_update :ensure_another_administrator_remains, if: :leaving_administrator_role?
  before_destroy :ensure_another_administrator_remains, if: :admin?

  # A single hook, rather than a broadcast call in every controller action that
  # happens to add, remove or re-role somebody.
  after_commit :broadcast_user_counters, if: :counters_affected?

  # `searchable_text` is a stored generated column -- the name and the address
  # concatenated by PostgreSQL -- carrying a trigram index. Searching one
  # indexed expression rather than two columns joined by OR is what lets the
  # planner use the index at all: with an index per column it compares two GIN
  # scans against one sequential scan and chooses the sequential scan.
  scope :search, lambda { |term|
    next all if term.blank?

    where("searchable_text ILIKE :term", term: "%#{sanitize_sql_like(term.to_s.strip)}%")
  }

  scope :with_role, lambda { |role|
    next all unless roles.key?(role.to_s)

    where(role: role)
  }

  scope :ordered, -> { order(:full_name, :id) }

  def self.role_counts
    group(:role).count.transform_keys(&:to_s)
  end

  # Upload wins, then the remote URL, then initials. Callers render from this
  # rather than each deciding the precedence for themselves.
  def avatar_source
    # Persisted, not merely assigned: a rejected upload is still attached in
    # memory while the form is re-rendered, and asking Active Storage to build
    # a thumbnail of it would raise.
    return :attachment if avatar.attached? && avatar.attachment.persisted?
    return :remote if displayable_avatar_url.present?

    :initials
  end

  # The single gate the URL has to pass, used both by the validation and by the
  # view. A rejected value is still sitting on the record while the form is
  # re-rendered, so checking only on save would put an unvalidated string into
  # an img src -- which is how a javascript: URL reaches the page.
  def displayable_avatar_url
    return if avatar_url.blank?

    uri = URI.parse(avatar_url)
    avatar_url if AVATAR_URL_SCHEMES.include?(uri.scheme) && uri.host.present?
  rescue URI::InvalidURIError
    nil
  end

  private

  # The content type on an upload is supplied by the client and can say
  # anything, so the file is sniffed instead. A shell script named avatar.png
  # and announced as image/png does not get through.
  def acceptable_avatar
    io = uploaded_avatar_io
    return if io.nil?

    errors.add(:avatar, :too_large, limit: MAX_AVATAR_BYTES / 1.megabyte) if io.size > MAX_AVATAR_BYTES

    detected = Marcel::MimeType.for(io)
    errors.add(:avatar, :invalid_type) unless AVATAR_CONTENT_TYPES.include?(detected)
  ensure
    io.rewind if io.respond_to?(:rewind)
  end

  def uploaded_avatar_io
    attachable = attachment_changes["avatar"]&.attachable
    return if attachable.blank?

    return attachable.tempfile if attachable.respond_to?(:tempfile)

    attachable if attachable.respond_to?(:size) && attachable.respond_to?(:read)
  end

  # Deliberately does not fetch anything. Validating a URL by requesting it is
  # how an attacker gets the server to make requests on their behalf, so the
  # URL is only ever checked as text and then handed to the browser as an
  # img src.
  def avatar_url_is_an_ordinary_web_url
    errors.add(:avatar_url, :unsupported_scheme) if displayable_avatar_url.nil?
  end

  def counters_affected?
    destroyed? || previously_new_record? || saved_change_to_role?
  end

  def broadcast_user_counters
    UserCounters.broadcast
  end

  def leaving_administrator_role?
    role_changed? && role_was == "admin"
  end

  def ensure_another_administrator_remains
    return if other_administrators_exist?

    errors.add(:base, :last_administrator)
    throw :abort
  end

  # `FOR UPDATE` holds the remaining administrator rows for the rest of the
  # surrounding transaction. Without it two concurrent demotions could each
  # see the other as the one still standing and leave the system with none.
  # An aggregate cannot be locked in PostgreSQL, so this selects ids.
  def other_administrators_exist?
    self.class.where(role: :admin).where.not(id: id).lock.ids.any?
  end
end
