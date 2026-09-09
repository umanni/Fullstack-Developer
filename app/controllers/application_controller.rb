class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private
    def after_authentication_url
      session.delete(:return_to_after_authenticating) || (Current.user&.admin? ? admin_root_path : profile_path)
    end
end
