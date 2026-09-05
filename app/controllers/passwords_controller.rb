class PasswordsController < ApplicationController
  allow_unauthenticated_access
  skip_after_action :verify_authorized
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Tente novamente mais tarde." }

  def new
  end

  def create
    if user = User.find_by(email: params[:email])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Instruções de redefinição enviadas (caso o e-mail exista)."
  end

  def edit
  end

  def update
    if @user.update(password_params)
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Sua senha foi redefinida."
    else
      redirect_to edit_password_path(params[:token]), alert: "As senhas não coincidem."
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "O link de redefinição é inválido ou expirou."
    end

    def password_params
      params.expect(user: [ :password, :password_confirmation ])
    end
end
