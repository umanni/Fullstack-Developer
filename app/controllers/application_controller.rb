class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  stale_when_importmap_changes

  private
    def after_authentication_url
      session.delete(:return_to_after_authenticating) || home_url_for(Current.user)
    end

    def redirect_if_authenticated
      redirect_to home_url_for(Current.user), status: :see_other if authenticated?
    end

    def revoke_other_sessions_for(user)
      return unless user.saved_change_to_password_digest?

      user.sessions.where.not(id: Current.session&.id).destroy_all
    end

    def home_url_for(user)
      user.admin? ? admin_dashboard_url : profile_url
    end

    # Blank password fields mean "not touched", not "clear it". A blanked full_name
    # still has to fail validation, so this is not compact_blank.
    def without_untouched_fields(permitted)
      permitted = permitted.except(:password, :password_confirmation) if permitted[:password].blank?
      # Anything that is not an upload — a blank input, or a string a client invented —
      # is dropped: Active Storage reads a string as a signed id and raises on it.
      permitted = permitted.except(:avatar_image) unless permitted[:avatar_image].is_a?(ActionDispatch::Http::UploadedFile)
      permitted
    end
end
