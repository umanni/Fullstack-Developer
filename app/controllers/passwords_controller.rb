class PasswordsController < InertiaController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Try again later." }

  def new
    render inertia: "Auth/ForgotPassword"
  end

  def create
    email = params.expect(password: [ :email ])[:email].to_s.strip.downcase
    if user = User.find_by(email:)
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  end

  def edit
    render inertia: "Auth/ResetPassword", props: { token: params[:token] }
  end

  def update
    if @user.update(params.expect(user: %i[ password password_confirmation ]))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Password has been reset."
    else
      redirect_to edit_password_path(params[:token]), inertia: { errors: @user.errors }
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
