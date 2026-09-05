class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  skip_after_action :verify_authorized
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Tente novamente mais tarde." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "E-mail ou senha incorretos."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
