class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  inertia_share auth: -> {
    if authenticated?
      { user: { id: Current.user.id, full_name: Current.user.full_name, email: Current.user.email, role: Current.user.role } }
    else
      { user: nil }
    end
  }

  private
    def after_authentication_url
      session.delete(:return_to_after_authenticating) || (Current.user&.admin? ? admin_root_path : profile_path)
    end
end
