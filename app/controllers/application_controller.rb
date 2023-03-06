class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    if current_user.role == true
      stored_location_for(resource) || admin_dashboard_path
    else
      stored_location_for(resource) || users_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :role, :photo])
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :role, :photo])
  end
end
