module Users
  class DashboardBroadcaster
    def self.call
      new.call
    end

    def call
      stats = DashboardStats.call

      Turbo::StreamsChannel.broadcast_replace_to(
        "admin_dashboard",
        target: "dashboard_stats",
        partial: "admin/dashboard/stats",
        locals: { stats: stats }
      )
    end
  end
end
