# frozen_string_literal: true

module Dashboard
  # Publishes the current dashboard totals to the "dashboard_stats" stream so
  # the admin panel updates without a reload. Reuses Dashboard::TotalsQuery +
  # Users::Overview#to_inertia — identical shape to the initial render (DRY).
  class Publisher
    STREAM = "dashboard_stats"

    def self.call
      new.call
    end

    def call
      overview = Dashboard::TotalsQuery.call(User.all)
      ActionCable.server.broadcast(STREAM, overview.to_inertia)
    end
  end
end
