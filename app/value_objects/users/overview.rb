# frozen_string_literal: true

module Users
  # Immutable frontier data for the admin dashboard. #to_inertia is the
  # serialization contract shared with the real-time broadcast (Phase 6).
  class Overview
    def initialize(total_users:, by_role:)
      @total_users = total_users
      @by_role = by_role.freeze
      freeze
    end

    attr_reader :total_users, :by_role

    def to_inertia
      {
        total_users: total_users,
        by_role: by_role
      }
    end
  end
end
