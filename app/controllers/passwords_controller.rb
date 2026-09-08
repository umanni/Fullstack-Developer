class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new
    render inertia: "Auth/ForgotPassword", props: {
      urls: { login_url: new_session_path }
    }
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  end

  def edit
    render inertia: "Auth/ResetPassword", props: {
      token: params[:token],
      urls: { login_url: new_session_path }
    }
  end

  def update
    form = Users::PasswordResetForm.new(params.permit(:password, :password_confirmation), user: @user)

    if form.update
      redirect_to new_session_path, notice: "Password has been reset."
    else
      render inertia: "Auth/ResetPassword", props: {
        token: params[:token],
        errors: form.errors.to_hash,
        urls: { login_url: new_session_path }
      }
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_token_for!(:password_reset, params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
