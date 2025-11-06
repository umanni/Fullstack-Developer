class Admin::DashboardController < ApplicationController
  def show
    @total_users = User.count
    @users_by_role = User.group(:role).count
  end
end
