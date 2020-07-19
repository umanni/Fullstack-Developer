class AdminController < ApplicationController
  before_action :authenticate_admin!

  private
    def authenticate_admin!
      redirect_to after_sign_in_path_for(current_user), status: :unauthorized unless current_user.admin?
    end
end
