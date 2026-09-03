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
end
