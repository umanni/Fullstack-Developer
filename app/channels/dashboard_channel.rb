class DashboardChannel < ApplicationCable::Channel
  def subscribed
    return reject unless current_user&.admin?

    stream_from Dashboard::Broadcaster::STREAM
  end
end
