module Authorization
  extend ActiveSupport::Concern

  class_methods do
    def require_admin!(**options)
      before_action :require_admin, **options
    end
  end

  private

  def require_admin
    return if Current.user&.admin?

    redirect_to after_authentication_url_for(Current.user), alert: "You are not authorized to access that area."
  end

  def after_authentication_url_for(user)
    return admin_root_path if user&.admin?

    profile_path
  end
end
