class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :redirect_if_authenticated, only: :new
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: "Too many attempts. Try again later.", status: :see_other }

  def new
  end

  def create
    if (user = authenticate)
      start_new_session_for user
      redirect_to after_authentication_url
    else
      flash.now[:alert] = "Try another email address or password."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private
    # authenticate_by raises when a key is missing, so a half-filled form has to be a
    # failed login rather than a 500.
    def authenticate
      credentials = params.expect(session: [ :email, :password ])
      return if credentials[:email].blank? || credentials[:password].blank?

      User.authenticate_by(credentials)
    end
end
