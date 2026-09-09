module Admin
  class DashboardController < BaseController
    def show
      render inertia: "Admin/Dashboard/Show", props: {
        total_users: User.count,
        users_by_role: User.group(:role).count
      }
    end
  end
end
