class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :redirect_authenticated_user, only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    email, password = params.expect(:email, :password)
    email = User.normalized_email(email)

    if user = User.authenticate_by(email:, password:)
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "The email or password is incorrect."
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: "You have been signed out.", status: :see_other
  end

  private
    def redirect_authenticated_user
      redirect_to(Current.user.admin? ? admin_root_path : profile_path) if authenticated?
    end
end
