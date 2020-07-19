class BroadcastDashboardDataJob < ApplicationJob
  queue_as :broadcast_dashboard_data

  def perform
    total_number_of_users_grouped = User.all.group(:role).count
    total_number_of_users = total_number_of_users_grouped.values.inject(&:+).to_i
    
    ActionCable.server.broadcast(
      "dashboard_channel",
      total_number_of_users_grouped: total_number_of_users_grouped, 
      total_number_of_users: total_number_of_users.to_s)

    BroadcastDashboardDataJob.set(wait: 10.seconds).perform_later
  end
end
