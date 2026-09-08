# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  included do
    before_action :require_admin
    helper_method :current_administrator?
  end

  private

  def current_administrator?
    Users::Policy.admin?(Current.user)
  end

  def require_admin
    redirect_to root_path unless current_administrator?
  end
end
