class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  before_action :redirect_if_authenticated, only: :new
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_registration_path, alert: "Too many attempts. Try again later.", status: :see_other }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      # Not after_authentication_url: a visitor who was bounced off /admin has that URL
      # stored, and honouring it here answers a new account with "not authorised".
      session.delete(:return_to_after_authenticating)
      redirect_to home_url_for(@user), notice: "Welcome to Umanni."
    else
      render :new, status: :unprocessable_content
    end
  end

  private
    def registration_params
      params.expect(user: [ :full_name, :email, :password, :password_confirmation ])
    end
end
