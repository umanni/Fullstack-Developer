module Api
  # The JSON side of the application. It descends from ActionController::API
  # rather than from ApplicationController: there is no session, no flash and
  # no CSRF token here, because a bearer token is the whole of the credential.
  class BaseController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate

    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    attr_reader :current_user

    def authenticate
      token = request.headers["Authorization"].to_s[/\ABearer (.+)\z/, 1]
      @current_user = User.find_by_token_for(:api, token) if token.present?

      unauthorized if @current_user.nil?
    end

    def require_admin
      forbidden unless current_user.admin?
    end

    def unauthorized
      render json: { error: "unauthorized" }, status: :unauthorized
    end

    def forbidden
      render json: { error: "forbidden" }, status: :forbidden
    end

    def not_found
      render json: { error: "not_found" }, status: :not_found
    end

    def unprocessable(record)
      render json: { error: "invalid", details: record.errors.to_hash(true) },
             status: :unprocessable_content
    end
  end
end
