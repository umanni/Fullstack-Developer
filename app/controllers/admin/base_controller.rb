module Admin
  class BaseController < ApplicationController
    before_action :require_admin

    private
      def require_admin
        return if Current.user.admin?

        redirect_to profile_path, alert: "You are not authorized to access that page."
      end
  end
end
