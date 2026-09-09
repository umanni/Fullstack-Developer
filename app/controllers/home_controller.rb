class HomeController < ApplicationController
  allow_unauthenticated_access only: [ :index ]

  def index
    if authenticated?
      redirect_to(Current.user&.admin? ? admin_root_path : profile_path)
    else
      redirect_to new_session_path
    end
  end
end
