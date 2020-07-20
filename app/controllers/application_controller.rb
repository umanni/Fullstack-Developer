class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_index_path
    else
      user_profile_path
    end
  end

  def layout_by_resource
    if devise_controller? && !request.fullpath.match?('/users/edit') && !(request.fullpath.match('/users') && params[:action] == 'update')
      'login'
    else
      'application'
    end
  end

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :avatar, :avatar_url])
      devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :avatar, :avatar_url])
    end
end
