class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?


  def after_sign_in_path_for(resource)
  if resource.admin?
    admin_users_path   # rota do index de usuários no dashboard admin
  else
    root_path
  end
end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :email, :avatar_image ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :email, :avatar_image ])
  end
end
