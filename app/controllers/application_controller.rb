# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_sign_up_params, if: :devise_controller?
  protect_from_forgery with: :exception

  def authenticate_admin_user!
    unless !current_user.nil? && current_user.admin?
      redirect_to root_path
    end
  end

  def after_sign_in_path_for(user)
    if (user.admin?)
      admin_dashboard_path
    else
      root_path
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :photo])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :photo])
  end
end
