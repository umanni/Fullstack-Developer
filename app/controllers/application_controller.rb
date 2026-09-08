class ApplicationController < ActionController::Base
  include Authentication
  before_action :set_inertia_shared_auth
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def set_inertia_shared_auth
    inertia_share auth: { user: -> { auth_user_json } }
  end

  def auth_user_json
    return nil unless Current.user

    UserPresenter.new(Current.user).to_inertia
  end
end
