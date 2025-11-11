module Authorizable
  extend ActiveSupport::Concern

  included do
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized if defined?(Pundit)
  end

  private

  def require_admin!
    unless user_signed_in?
      redirect_to new_user_session_path, alert: 'Você precisa fazer login antes de continuar.'
      return
    end

    unless current_user.admin?
      redirect_to root_path, alert: 'Acesso restrito a administradores'
    end
  end

  def require_user!
    authenticate_user!
  end

  def user_not_authorized
    flash[:alert] = 'Você não tem autorização para realizar esta ação.'
    redirect_to(request.referrer || root_path)
  end
end