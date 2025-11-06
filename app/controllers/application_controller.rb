class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?
  allow_browser versions: :modern
  before_action :authenticate_user!


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sing_up, keys: [ :full_name, :avatar_image, :avatar_url ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :full_name, :avatar_url, :avatar_image ])
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :full_name, :avatar_image, :avatar_url ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :full_name, :avatar_image, :avatar_url ])
  end
end
