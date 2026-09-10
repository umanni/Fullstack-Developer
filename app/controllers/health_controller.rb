class HealthController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token

  def show
    ActiveRecord::Base.connection.execute("SELECT 1")
    render json: { status: "ok" }, status: :ok
  rescue ActiveRecord::ConnectionNotEstablished, PG::Error
    render json: { status: "unavailable" }, status: :service_unavailable
  end
end
