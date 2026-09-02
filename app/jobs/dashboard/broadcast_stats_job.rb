module Dashboard
  class BroadcastStatsJob < ApplicationJob
    queue_as :default

    def perform
      Turbo::StreamsChannel.broadcast_replace_to(
        "admin_dashboard",
        target: "dashboard_stats",
        partial: "admin/dashboard/stats",
        locals: { stats: Stats.call }
      )
    end
  end
end
