class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path
    else
      profile_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :full_name, :avatar_url ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :full_name, :avatar_url, :avatar_image ])
  end

  def ensure_admin!
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end

  def ensure_user_or_admin!(user)
    redirect_to root_path, alert: "Access denied." unless current_user == user || current_user&.admin?
  end
end
