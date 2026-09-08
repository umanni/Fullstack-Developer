# frozen_string_literal: true

module Admin
  # Admin write use case: manages any user, including their role. Inherits the
  # common user validations from Users::Form (DRY). A password is required only
  # when creating a user; on update it is optional (use-case rule).
  class UserForm < Users::Form
    attribute :password, :string
    attribute :password_confirmation, :string
    attribute :role, :string

    validates :role, inclusion: { in: User.roles.keys }
    validates :password, presence: true, length: { in: 8..72 }, if: :new_record?
    validates :password, length: { in: 8..72 }, if: :password_chosen?
    validates :password_confirmation, presence: true, if: :password_chosen?
    validate :password_confirmation_match, if: :password_chosen?

    private

    def user_attributes
      attributes = super.merge(role: role)
      return attributes unless password.present?

      attributes.merge(password: password, password_confirmation: password_confirmation)
    end

    def new_record?
      user.new_record?
    end

    def password_chosen?
      password.present?
    end

    def password_confirmation_match
      errors.add(:password_confirmation, :confirmation) unless password == password_confirmation
    end
  end
end
