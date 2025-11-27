class UserImportPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin?
  end

  def create?
    user&.admin?
  end

  def new?
    create?
  end

  def status?
    show?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user&.admin?

      scope.all
    end
  end
end

