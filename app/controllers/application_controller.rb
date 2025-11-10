class ApplicationController < ActionController::Base
  include Authorizable
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name])
  end

  # redirecionamento após login
  def after_sign_in_path_for(resource)
    if resource.admin?
      dashboard_index_path
    else
      dashboard_index_path # Por enquanto todos vão para dashboard
    end
  end

  # redirecionamento após cadastro
  def after_sign_up_path_for(resource)
    dashboard_index_path
  end
end