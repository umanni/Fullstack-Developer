class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || own_record?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || own_record?
  end

  def destroy?
    user.admin? || own_record?
  end

  def toggle_role?
    user.admin?
  end

  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.where(id: user.id)
    end
  end

  private
    def own_record?
      record == user
    end
end
