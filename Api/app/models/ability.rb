class Ability
  include CanCan::Ability
  def initialize(user)
    alias_action :read, :current, :update, :update_password, :destroy, to: :no_admin
    can :no_admin, User
    return unless user
    can :manage, :all if user.role == "admin"
  end
end