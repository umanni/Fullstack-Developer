# frozen_string_literal: true

module Users
  # Forgot-password write use case: changes ONLY the password of an existing
  # user whose reset token was already verified by the controller. Extends the
  # common user validation contract so no User write bypasses the Form
  # hierarchy (DIP/DRY); identity fields are prefilled from the target record
  # and never rewritten. The avatar rule is out of scope for this intent.
  class PasswordResetForm < Form
    attribute :password, :string
    attribute :password_confirmation, :string
    attribute :require_avatar, :boolean, default: false

    validates :password, presence: true, length: { in: 8..72 }
    validates :password_confirmation, presence: true
    validate :password_confirmation_match

    def initialize(attributes = {}, user:)
      identity = {
        full_name: user.full_name,
        email_address: user.email_address
      }.merge(attributes)

      super(identity, user: user)
    end

    private

    def user_attributes
      {
        password: password,
        password_confirmation: password_confirmation
      }
    end

    def password_confirmation_match
      errors.add(:password_confirmation, :confirmation) unless password == password_confirmation
    end
  end
end
