# frozen_string_literal: true

module Users
  # Own-profile write use case: full_name, email_address, avatar and an
  # OPTIONAL password. Never manages a role or other users (ISP).
  class ProfileForm < Form
    attribute :password, :string
    attribute :password_confirmation, :string

    validates :password, length: { in: 8..72 }, if: :password_chosen?
    validates :password_confirmation, presence: true, if: :password_chosen?
    validate :password_confirmation_match, if: :password_chosen?

    private

    def user_attributes
      return super unless password.present?

      super.merge(password: password, password_confirmation: password_confirmation)
    end

    def password_chosen?
      password.present?
    end

    def password_confirmation_match
      errors.add(:password_confirmation, :confirmation) unless password == password_confirmation
    end
  end
end
