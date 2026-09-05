class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  skip_after_action :verify_authorized
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Tente novamente mais tarde." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.role = :no_admin

    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "Bem-vindo! Sua conta foi criada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def registration_params
      params.expect(user: [ :full_name, :email, :password, :password_confirmation ])
    end
end
