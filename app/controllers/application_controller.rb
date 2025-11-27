class ApplicationController < ActionController::Base
  include PunditHelper

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :avatar_url])
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      profile_path
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end
end

