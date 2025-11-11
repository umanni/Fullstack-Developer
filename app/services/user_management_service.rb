class UserManagementService < ApplicationService
  def initialize(user_params, current_user)
    @user_params = user_params
    @current_user = current_user
  end

  def call
    if can_perform_action?
      create_or_update_user
    else
      failure("You do not have permission to perform this action")
    end
  end

  private

  attr_reader :user_params, :current_user

  def can_perform_action?
    current_user&.admin?
  end

  def create_or_update_user
    if user_params[:id].present?
      update_existing_user
    else
      create_new_user
    end
  end

  def update_existing_user
    user = User.find(user_params[:id])

    if user.update(filtered_params)
      success(user)
    else
      failure(user.errors)
    end
  rescue ActiveRecord::RecordNotFound
    failure("User not found")
  end

  def create_new_user
    params_with_password = filtered_params.merge(
      password: generate_secure_password,
      password_confirmation: nil
    )

    user = User.new(params_with_password)

    if user.save
      UserMailer.welcome_email(user, params_with_password[:password]).deliver_later
      success(user)
    else
      failure(user.errors)
    end
  end

  def filtered_params
    user_params.permit(:full_name, :email, :role, :avatar_url, :avatar_image)
  end

  def generate_secure_password
    SecureRandom.alphanumeric(12)
  end
end
