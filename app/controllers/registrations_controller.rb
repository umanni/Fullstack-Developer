# frozen_string_literal: true

class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    render inertia: "Auth/Register", props: {
      urls: {
        register_url: registration_path,
        login_url: new_session_path
      }
    }
  end

  def create
    form = Users::RegistrationForm.new(registration_params)

    if form.save
      start_new_session_for(form.user)
      redirect_to after_authentication_url, notice: "Signed up successfully."
    else
      render inertia: "Auth/Register", props: {
        urls: {
          register_url: registration_path,
          login_url: new_session_path
        },
        form: echoed_attributes,
        errors: form.errors.to_hash
      }
    end
  end

  private

  def registration_params
    params.permit(:full_name, :email_address, :avatar, :avatar_url, :password, :password_confirmation)
  end

  def echoed_attributes
    params.permit(:full_name, :email_address, :avatar_url).to_h
  end
end
