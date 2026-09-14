module Admin
  class BaseController < ApplicationController
    before_action :require_admin

    private
      # See Other, not the default Found: a client that follows a 302 keeps the method, so
      # a refused DELETE reaches the redirect target as another DELETE.
      def require_admin
        return if Current.user.admin?

        redirect_to profile_url, alert: "You are not authorised to access that page.", status: :see_other
      end
  end
end
