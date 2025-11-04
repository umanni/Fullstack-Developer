module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_user!  # garante login
    before_action :require_admin        # garante que só admins acessem
    before_action :set_admin_counters

    private

    def require_admin
      return if current_user.admin?

      flash[:alert] = "Você não tem permissão para acessar essa página."
      redirect_to root_path
    end

    # Define contadores usados em várias views do painel admin
    def set_admin_counters
      @users_count = User.count
      # enum scopes gerados no modelo User: .admin e .user
      @admins_count = User.admin.count
      @normal_users_count = User.user.count
    end
  end
end
