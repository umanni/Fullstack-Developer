class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :redirect_authenticated_user

  def new
    @user = User.new
  end

  def create
    @user = Users::Create.call(attributes: registration_params.merge(role: :user))

    if @user.persisted?
      start_new_session_for(@user)
      redirect_to profile_path, notice: "Welcome! Your account is ready."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def registration_params
      params.expect(user: %i[ full_name email avatar_image avatar_image_url password password_confirmation ])
    end

    def redirect_authenticated_user
      redirect_to(Current.user.admin? ? admin_root_path : profile_path) if authenticated?
    end
end
