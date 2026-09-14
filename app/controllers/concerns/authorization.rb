module Authorization
  extend ActiveSupport::Concern

  class NotAuthorizedError < StandardError; end

  included do
    rescue_from NotAuthorizedError, with: :deny_access
  end

  private

  def authorize!(record, action = "#{action_name}?")
    policy = policy_for(record)
    raise NotAuthorizedError unless policy.public_send(action)
    policy
  end

  def policy_for(record)
    klass = record.is_a?(Class) ? record : record.class
    "#{klass.name}Policy".constantize.new(Current.user, record)
  end

  def permitted_params(record, key)
    params.expect(key => policy_for(record).permitted_attributes)
  end

  def deny_access
    redirect_back fallback_location: root_path, alert: "You are not authorized to do that."
  end
end
