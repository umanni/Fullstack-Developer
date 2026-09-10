class ApplicationController < ActionController::Base
  include Authentication
  # Cross-browser support: Rails modern-browser guard; all UI is standard HTML/CSS/React with no browser-specific APIs.
  allow_browser versions: :modern

  inertia_share auth: -> {
    if authenticated?
      { user: { id: Current.user.id, full_name: Current.user.full_name, email: Current.user.email, role: Current.user.role } }
    else
      { user: nil }
    end
  }, flash: -> {
    { notice: flash[:notice], alert: flash[:alert] }
  }

  private
    def after_authentication_url
      session.delete(:return_to_after_authenticating) || (Current.user&.admin? ? admin_root_path : profile_path)
    end
end
