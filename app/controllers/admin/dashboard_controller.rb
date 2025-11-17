class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    users = User.all
    @total_users = users.size
    @total_admins = users.count(&:admin?)
    @total_regulars = @total_users - @total_admins
  end

  private
end
