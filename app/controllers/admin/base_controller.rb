class Admin::BaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    unless current_user.admin?
      flash[:alert] = "You must be an admin to access this section."
      redirect_to profile_path
    end
  end
end
