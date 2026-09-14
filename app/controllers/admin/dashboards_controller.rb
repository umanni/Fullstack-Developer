module Admin
  class DashboardsController < BaseController
    def show
      @counts_by_role = User.group(:role).count
      @total = @counts_by_role.values.sum
    end
  end
end
