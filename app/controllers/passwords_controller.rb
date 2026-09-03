class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[edit update]
  rate_limit to: 10, within: 3.minutes, only: :create, with: lambda {
    redirect_to new_password_path, alert: t("passwords.throttled")
  }

  def new; end

  def edit; end

  def create
    if (user = User.find_by(email_address: params[:email_address]))
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: t("passwords.reset_instructions_sent")
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: t("passwords.reset")
    else
      redirect_to edit_password_path(params[:token]), alert: t("passwords.mismatch")
    end
  end

  private

  def set_user_by_token
    @user = User.find_by!(password_reset_token: params.expect(:token))
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: t("passwords.invalid_token")
  end
end
