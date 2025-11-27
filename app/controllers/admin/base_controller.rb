class Admin::BaseController < ApplicationController
  layout 'admin'
  
  before_action :ensure_admin

  private

  def ensure_admin
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end
end

