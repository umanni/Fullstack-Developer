class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :admin, :avatar_image])
      devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :admin, :avatar_image])
    end

    # def after_sign_in_path_for(resource)
    #   redirect_to users_backoffice_welcome_index_path
    # end
  
end
