module Api
  module V1
    # Exchanges an email address and a password for a bearer token. The token
    # is signed rather than stored: there is no table of secrets to leak, and
    # changing a password invalidates every token already issued.
    class TokensController < BaseController
      skip_before_action :authenticate

      rate_limit to: 10, within: 3.minutes, with: -> { render_throttled }

      def create
        user = User.authenticate_by(email_address: params[:email_address].to_s,
                                    password: params[:password].to_s)
        return unauthorized if user.nil?

        render json: {
          token: user.generate_token_for(:api),
          expires_at: User::API_TOKEN_VALID_FOR.from_now.iso8601,
          user: UserSerializer.new(user).as_json
        }, status: :created
      end

      private

      def render_throttled
        render json: { error: "too_many_requests" }, status: :too_many_requests
      end
    end
  end
end
