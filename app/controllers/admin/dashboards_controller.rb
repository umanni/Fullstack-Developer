class Admin::DashboardsController < ApplicationController
  def show
    authorize User, :index?
    counts = User.dashboard_counts
    @total_users = counts[:total_users]
    @users_by_role = counts[:users_by_role]
  end
end
