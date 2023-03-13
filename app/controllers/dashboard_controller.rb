class DashboardController < ApplicationController
  def index
    @total_users = User.count
    @users_by_role = User.group(:role).count
  end

  def list_users
    @users = User.all
  end
end
