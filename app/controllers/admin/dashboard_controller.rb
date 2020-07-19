class Admin::DashboardController < AdminController
  def index
    @total_number_of_users_grouped = User.all.group(:role).count
    @total_number_of_users = @total_number_of_users_grouped.values.inject(&:+).to_i
  end
end
