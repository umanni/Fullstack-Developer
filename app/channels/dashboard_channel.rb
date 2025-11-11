class DashboardChannel < ApplicationCable::Channel
  def subscribed
    # Only allow admin users to subscribe to dashboard updates
    if current_user&.admin?
      stream_from "dashboard_updates"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
