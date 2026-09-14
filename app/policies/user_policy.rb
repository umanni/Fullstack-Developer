class UserPolicy < ApplicationPolicy
  BASE_ATTRIBUTES  = %i[full_name email_address password password_confirmation
                        avatar_url avatar_image].freeze
  ADMIN_ATTRIBUTES = (BASE_ATTRIBUTES + %i[role]).freeze

  def index?   = user.admin?
  def show?    = user.admin? || owner?
  def create?  = user.admin?
  def update?  = user.admin? || owner?
  def destroy? = user.admin? || owner?

  def toggle_role? = user.admin? && !owner?

  def permitted_attributes
    toggle_role? ? ADMIN_ATTRIBUTES : BASE_ATTRIBUTES
  end

  def scope
    user.admin? ? User.all : User.where(id: user.id)
  end
end
