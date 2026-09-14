# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_registration_path, alert: "Try again later." }
  before_action :redirect_if_authenticated

  def new
    render inertia: "Auth/Register"
  end

  def create
    user = User.new(registration_params.merge(role: :member))

    if user.save
      start_new_session_for user
      redirect_to profile_path, notice: "Welcome, #{user.full_name}."
    else
      redirect_to new_registration_path, inertia: { errors: user.errors }
    end
  end

  private

  def registration_params
    params.expect(user: %i[full_name email_address password password_confirmation])
  end

  def redirect_if_authenticated
    redirect_to root_path if authenticated?
  end
end
