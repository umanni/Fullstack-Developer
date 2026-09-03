module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      stored_url = @return_to_after_authenticating || session.delete(:return_to_after_authenticating)
      return stored_url if stored_url.present? && URI.parse(stored_url).host == request.host

      Current.user.admin? ? admin_root_url : profile_url
    rescue URI::InvalidURIError
      Current.user.admin? ? admin_root_url : profile_url
    end

    def start_new_session_for(user)
      @return_to_after_authenticating = session.delete(:return_to_after_authenticating)
      reset_session
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = {
          value: session.id,
          httponly: true,
          same_site: :lax,
          secure: request.ssl?
        }
      end
    end

    def terminate_session
      Current.session&.destroy
      Current.reset
      reset_session
      cookies.delete(:session_id)
    end
end
