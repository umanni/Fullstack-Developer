class Admin::DashboardsController < Admin::BaseController
  def show
    @total_users = User.count
    @total_admins = User.admins.count
    @total_regular_users = User.regular_users.count
    @total_guests = User.guests.count
    @users_by_role = {
      admin: @total_admins,
      user: @total_regular_users,
      guest: @total_guests
    }
  end
end

