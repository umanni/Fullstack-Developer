module Api
  module V1
    # Whoever the token belongs to. Nothing here reads an identifier from the
    # request, so there is nothing to tamper with.
    class ProfilesController < BaseController
      def show
        render json: UserSerializer.new(current_user).as_json
      end
    end
  end
end
