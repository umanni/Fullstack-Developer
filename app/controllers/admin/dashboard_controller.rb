module Admin
  class DashboardController < ApplicationController
    layout 'admin'
    
    include Authorizable
    before_action :require_admin!

    def index
      require_admin!

      metrics = {
        total_users: User.count,
        users_by_role: {
          admin: User.admin.count,
          user: User.user.count
        }
      }

      respond_to do |format|
        format.json { render json: metrics }
        format.html { render json: metrics }
      end
    end
  end
end
