class AdminDashboardChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user.admin?
    stream_from "admin_dashboard"
  end
end
