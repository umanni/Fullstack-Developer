class AdminDashboardBroadcastJob < ApplicationJob
  queue_as :default

  def perform
    total_users = User.count
    total_admins = User.admins.count
    total_regular_users = User.regular_users.count
    total_guests = User.guests.count

    ActionCable.server.broadcast(
      'admin_dashboard',
      {
        total_users: total_users,
        total_admins: total_admins,
        total_regular_users: total_regular_users,
        total_guests: total_guests,
        users_by_role: {
          admin: total_admins,
          user: total_regular_users,
          guest: total_guests
        }
      }
    )
  end
end

