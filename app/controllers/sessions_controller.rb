class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Tente novamente mais tarde." }

  def new
    redirect_to(default_authenticated_url) if authenticated?
  end

  def create
    if (user = User.authenticate_by(email: params[:email], password: params[:password]))
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Login realizado com sucesso."
    else
      redirect_to new_session_path, alert: "E-mail ou senha inválidos."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other, notice: "Você saiu da conta."
  end
end
