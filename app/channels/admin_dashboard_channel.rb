class AdminDashboardChannel < ApplicationCable::Channel
  def subscribed
    return reject unless current_user&.admin?

    stream_from 'admin_dashboard'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

