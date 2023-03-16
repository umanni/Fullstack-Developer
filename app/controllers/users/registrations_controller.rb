# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    upload_avatar_image if params[:user][:avatar_image].present?
    super
  end

  # GET /resource/edit
  def edit
    @user = User.find(params[:id])
    super
  end

  # PUT /resource
  # PUT /resource
  def update
    if @user.update(configure_account_update_params)
      redirect_to show_user_profile_path(@user)
    else
      render :edit
    end
  end


  # DELETE /resource
  def destroy
    @user.destroy
    redirect_to dashboard_path, notice: 'User was successfully deleted.'
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  private

  def set_user
    @user = User.find(params[:id])
  end
  
  def upload_avatar_image
    uploader = AvatarImageUploader.new
    uploader.store!(params[:user][:avatar_image])
    params[:user][:avatar_image] = uploader.url
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :avatar_image, :role])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    permitted_params = devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :avatar_image, :role, :email, :password, :password_confirmation])
    permitted_params.present? ? permitted_params[:user] : {}
  end



  # The path used after sign up. Send to dashboard if user is admin or to the user profile if user is user
  def after_sign_up_path_for(resource)
    if resource.role == 'admin'
      dashboard_path
    else
      show_user_profile(resource)
    end
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end