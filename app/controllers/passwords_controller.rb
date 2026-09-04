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
      redirect_to new_session_path, notice: t(@invited ? "passwords.chosen" : "passwords.reset")
    else
      redirect_to edit_password_path(params[:token]), alert: t("passwords.mismatch")
    end
  end

  private

  # The same screen serves two arrivals: somebody who asked to reset a password
  # and somebody who was imported and has never had one. Both links carry a
  # token derived from the password salt, so both stop working once a password
  # is set; only the purpose and the wording differ.
  def set_user_by_token
    token = params.expect(:token)
    @user = User.find_by_password_reset_token(token)
    @invited = @user.nil?
    @user ||= User.find_by_token_for(:invitation, token)

    redirect_to new_password_path, alert: t("passwords.invalid_token") if @user.nil?
  end
end
