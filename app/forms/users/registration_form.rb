# frozen_string_literal: true

module Users
  # Registration use case: a visitor always becomes a regular :user.
  # The role rule is imposed here, never in the controller.
  class RegistrationForm < Form
    attribute :password, :string
    attribute :password_confirmation, :string

    validates :password, presence: true, length: { in: 8..72 }
    validates :password_confirmation, presence: true
    validate :password_confirmation_match

    def initialize(attributes = {}, user: nil)
      super(attributes, user: user, role: :user)
    end

    private

    def user_attributes
      super.merge(
        password: password,
        password_confirmation: password_confirmation
      )
    end

    def password_confirmation_match
      return if password.blank? || password_confirmation.blank?

      errors.add(:password_confirmation, :confirmation) unless password == password_confirmation
    end
  end
end
