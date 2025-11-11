class Admin::DashboardController < ApplicationController
  before_action :ensure_admin!

  def index
    result = DashboardStatsService.call(current_user)

    if result.success?
      stats = result.data
      @user_stats = stats[:users]
      @import_stats = stats[:imports]
      @activity_stats = stats[:activity]
      @growth_stats = stats[:growth]
      @recent_users = stats[:users][:recent]
    else
      redirect_to root_path, alert: result.error_messages.join(", ")
    end
  end
end
