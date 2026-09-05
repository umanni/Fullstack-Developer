class SpreadsheetImportPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def create?
    user.admin?
  end

  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.none
    end
  end
end
