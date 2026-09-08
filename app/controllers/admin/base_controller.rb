module Admin
  class BaseController < InertiaController
    before_action :require_administrator

    private
      def require_administrator
        return if Current.user.admin?

        redirect_to profile_path, alert: "You are not authorized to access that page."
      end
  end
end
