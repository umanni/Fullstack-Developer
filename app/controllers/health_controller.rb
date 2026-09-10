class HealthController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token

  def show
    ActiveRecord::Base.connection.execute("SELECT 1")
    render json: { status: "ok" }, status: :ok
  rescue ActiveRecord::ConnectionNotEstablished, ActiveRecord::ConnectionFailed,
         ActiveRecord::StatementInvalid, PG::Error => e
    Rails.logger.error("[HealthCheck] database unavailable: #{e.class}: #{e.message}")
    render json: { status: "unavailable" }, status: :service_unavailable
  end
end
