module Authorizable
  extend ActiveSupport::Concern

  included do
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized if defined?(Pundit)
  end

  private

  def require_admin!
    unless user_signed_in? && current_user.admin?
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end

  def require_user!
    authenticate_user!
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referrer || root_path)
  end
end