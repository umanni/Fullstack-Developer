# frozen_string_literal: true

module Dashboard
  # Single source of dashboard totals, reused by the initial render and by the
  # real-time broadcast (Phase 6) — DRY.
  class TotalsQuery
    def self.call(scope)
      new(scope).call
    end

    def initialize(scope)
      @scope = scope
    end

    def call
      Users::Overview.new(
        total_users: scope.count,
        by_role: scope.group(:role).count
      )
    end

    private

    attr_reader :scope
  end
end
