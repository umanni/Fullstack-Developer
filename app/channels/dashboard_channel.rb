class DashboardChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user&.admin?
    stream_from "dashboard_stats"
    transmit({ type: "stats", **User.dashboard_stats })
  end

  def self.broadcast_stats
    ActionCable.server.broadcast("dashboard_stats", { type: "stats", **User.dashboard_stats })
  end
end
