class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(resource)
    if current_user.admin == true
      return admin_users_path
    else
      return root_path
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :photo])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :photo])
  end
end
