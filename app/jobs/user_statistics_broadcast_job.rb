class UserStatisticsBroadcastJob < ApplicationJob
  queue_as :realtime

  def perform
    ActionCable.server.broadcast("admin_dashboard", UserStatistics.call)
  end
end
