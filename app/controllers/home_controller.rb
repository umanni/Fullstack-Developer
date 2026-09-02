class HomeController < ApplicationController
  allow_unauthenticated_access

  def show
    return unless authenticated?

    redirect_to Current.user.admin? ? admin_root_path : profile_path
  end
end
