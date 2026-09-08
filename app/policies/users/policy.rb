# frozen_string_literal: true

module Users
  # Policy object: single source of role invariants (DRY). Pure domain rules,
  # no HTTP. New role-based rules are added here, never in controllers.
  class Policy
    def self.admin?(user)
      new(user).admin?
    end

    def self.admin_reader?(user)
      new(user).admin?
    end

    def initialize(user)
      @user = user
    end

    def admin?
      @user&.admin?
    end

    def destructible?(actor, target)
      return false if actor == target
      return false if last_admin?(target)

      true
    end

    def demotable?(actor, target)
      return false if actor == target
      return false if last_admin?(target)

      true
    end

    private

    attr_reader :user

    def last_admin?(target)
      target.admin? && role_count_for(:admin) == 1
    end

    def role_count_for(role)
      User.where(role: role).count
    end
  end
end
