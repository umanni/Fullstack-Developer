class User < ApplicationRecord
  MAX_FULL_NAME_LENGTH = 120

  # The locales the interface is actually translated into. Keeping the list on
  # the model means the validation, the check constraint and the language
  # picker all read from one place.
  SUPPORTED_LOCALES = %w[en pt-BR es].freeze

  has_secure_password
  has_many :sessions, dependent: :destroy

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

  # The last administrator may not be removed or demoted. This lives on the
  # model rather than in a controller so it holds for every path into the
  # data: the admin screens, the console, a seed, a future import.
  before_update :ensure_another_administrator_remains, if: :leaving_administrator_role?
  before_destroy :ensure_another_administrator_remains, if: :admin?

  # A single hook, rather than a broadcast call in every controller action that
  # happens to add, remove or re-role somebody.
  after_commit :broadcast_user_counters, if: :counters_affected?

  scope :search, lambda { |term|
    next all if term.blank?

    pattern = "%#{sanitize_sql_like(term.to_s.strip)}%"
    where("full_name ILIKE :term OR email_address ILIKE :term", term: pattern)
  }

  scope :with_role, lambda { |role|
    next all unless roles.key?(role.to_s)

    where(role: role)
  }

  scope :ordered, -> { order(:full_name, :id) }

  def self.role_counts
    group(:role).count.transform_keys(&:to_s)
  end

  private

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
