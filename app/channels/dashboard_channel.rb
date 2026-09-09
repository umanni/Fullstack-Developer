class DashboardChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user&.admin?
    stream_from "dashboard"
  end
end
