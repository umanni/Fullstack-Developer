# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_sign_up_params, if: :devise_controller?
  rescue_from ActionController::RoutingError, with: :handle_routing_error
  rescue_from ActionController::UnknownFormat, with: :handle_unknown_format

  def route_not_found!
    raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
  end

  private

  def handle_routing_error
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", layout: false, status: :not_found }
      format.any  { head :not_found }
    end
  end

  def handle_unknown_format
    respond_to do |format|
      format.any  { head :not_implemented }
    end
  end

  def authenticate_admin_user!
    unless !current_user.nil? && current_user.admin?
      redirect_to root_path
    end
  end

  def after_sign_in_path_for(user)
    if (user.admin?)
      admin_dashboard_path
    else
      root_path
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :photo])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :photo])
  end
end
