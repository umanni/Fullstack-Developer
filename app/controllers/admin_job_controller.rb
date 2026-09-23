class AdminJobController < ApplicationController
  before_action :require_admin

  private

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to main_app.new_session_path
  end

  def require_admin
    return if current_user&.admin?

    redirect_to main_app.profile_path, alert: "Você não tem permissão para acessar essa área."
  end
end
