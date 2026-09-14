class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Try again later.", status: :see_other }

  def new
  end

  def create
    if (user = User.find_by(email: reset_request_params[:email]))
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "If that email address has an account, reset instructions are on the way."
  end

  def edit
  end

  def update
    # has_secure_password drops a blank assignment and the length rule allows nil, so an
    # empty submission saves cleanly and announces a reset that never happened.
    if new_password_params[:password].blank?
      @user.errors.add(:password, :blank)

      return render :edit, status: :unprocessable_content
    end

    if @user.update(new_password_params)
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Password has been reset."
    else
      # Re-rendering puts each error under the field that caused it. A single "passwords
      # did not match" for every failure hides a broken length rule.
      render :edit, status: :unprocessable_content
    end
  end

  private
    def reset_request_params
      params.expect(password_reset: [ :email ])
    end

    def new_password_params
      params.expect(password_reset: [ :password, :password_confirmation ])
    end

    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired.", status: :see_other
    end
end
