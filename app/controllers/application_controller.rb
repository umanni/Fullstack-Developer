class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :avatar_image, :role])
  end
  private
  def authenticate_role!
    authenticate_user!
    redirect_to :show, status: :forbidden unless current_user.role?
  end
end
