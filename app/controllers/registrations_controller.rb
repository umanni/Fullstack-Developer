class RegistrationsController < InertiaController
  allow_unauthenticated_access
  before_action :redirect_authenticated_user

  def new
    render inertia: "Auth/Register"
  end

  def create
    user = User.new(registration_params.merge(role: :user))

    if user.save
      start_new_session_for(user)
      redirect_to profile_path, notice: "Welcome! Your account has been created."
    else
      redirect_to new_registration_path, inertia: { errors: user.errors }
    end
  end

  private
    def registration_params
      params.expect(user: %i[ full_name email password password_confirmation avatar_image ])
    end

    def redirect_authenticated_user
      redirect_to after_authentication_url if authenticated?
    end
end
