class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :devise_permitted_parameters, if: :devise_controller?

  protected

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_admin!
    redirect_to root_path, alert: "Access denied." unless current_user.admin?
  end

  def devise_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :full_name, :avatar ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :full_name, :avatar ])
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_index_path
    else
      user_path(resource)
    end
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end
end
