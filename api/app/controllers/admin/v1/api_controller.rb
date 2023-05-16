module Admin::V1
  class ApiController < ApplicationController
    class ForbiddenAcess < StandardError; end

    include Authenticatable

    include SimpleErrorRenderable
    self.simple_error_partial = "shared/simple_error"

    before_action :restrict_access_for_admin!

    rescue_from ForbiddenAcess do
      render_error(message: "Forbidden access", status: :forbidden)
    end

    private

    def restrict_access_for_admin!
      raise ForbiddenAcess unless current_user.admin?
    end
  end
end
