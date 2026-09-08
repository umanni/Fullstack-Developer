class SessionsController < InertiaController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
    return redirect_to after_authentication_url if authenticated?

    render inertia: "Auth/Login"
  end

  def create
    credentials = params.expect(session: %i[ email password ])
    credentials[:email] = credentials[:email].to_s.strip.downcase

    if user = User.authenticate_by(credentials)
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path,
        inertia: { errors: { email: "Email or password is incorrect." } }
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path,
      status: :see_other,
      notice: "You have been signed out.",
      inertia: { clear_history: true }
  end
end
