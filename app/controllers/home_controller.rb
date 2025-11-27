class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    if user_signed_in?
      if current_user.admin?
        redirect_to admin_root_path
      else
        redirect_to profile_path
      end
    end
  end
end

