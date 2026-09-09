class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
    render inertia: "Registration/New"
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for @user
      redirect_to profile_path, notice: "Welcome!"
    else
      render inertia: "Registration/New", status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.expect(user: [ :full_name, :email, :password, :password_confirmation ])
    end
end
