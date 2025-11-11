module DashboardBroadcaster
  extend ActiveSupport::Concern

  included do
    after_commit :broadcast_dashboard_update, on: [ :create, :update, :destroy ]
  end

  private

  def broadcast_dashboard_update
    # Broadcast updated statistics to admin dashboard
    ActionCable.server.broadcast(
      "dashboard_updates",
      {
        type: "stats_update",
        stats: {
          total_users: User.total_count,
          admin_users: User.admin_count,
          users: User.user_count
        },
        timestamp: Time.current.iso8601
      }
    )
  end
end
