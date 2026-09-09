# Authorization is deliberately a small, explicit layer rather than a gem: the
# application has two roles and a handful of rules, and a policy framework
# would add indirection without removing any decisions.
module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :admin?
  end

  private

  def admin?
    Current.user&.admin? || false
  end

  # Sends a signed-in non-admin back to the only area they own. The admin area
  # is not a secret, so this says no plainly instead of pretending the route
  # does not exist.
  def require_admin
    return if admin?

    redirect_to profile_path, alert: t("authorization.admin_only")
  end
end
