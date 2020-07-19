class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_index_path
    else
      user_profile_path
    end
  end

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :avatar, :avatar_url])
      devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :avatar, :avatar_url])
    end
end
