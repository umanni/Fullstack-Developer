class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      redirect_to profile_path, notice: t("registrations.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  # `role` is absent by design. A visitor can only ever create a regular user,
  # and the column default is what assigns the role -- there is no code path
  # from this form to an administrator.
  def registration_params
    params.expect(user: %i[full_name email_address password password_confirmation])
  end
end
