class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pagy::Method

  protected

  def after_sign_in_path_for(resource)
    current_user.admin? ? admin_dashboard_path : profile_path
  end
end
