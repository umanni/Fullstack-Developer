class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :avatar_url])
  end

  def after_sign_up_path_for(_resource)
    profile_path
  end

  def build_resource(hash = {})
    super(hash.merge(role: :user))
  end
end

