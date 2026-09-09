module Api
  module V1
    # The administrative side of the API. The rules it enforces are the same
    # ones the HTML screens enforce, because they live in the model: the role
    # is only assignable here, and the last administrator is protected there.
    class UsersController < BaseController
      include Paginating

      before_action :require_admin
      before_action :set_user, only: %i[show update destroy]

      def index
        pagy, users = paginate(filtered_users)

        render json: {
          users: UserSerializer.collection(users),
          pagination: { page: pagy.page, pages: pagy.pages, count: pagy.count, limit: pagy.limit }
        }
      end

      def show
        render json: UserSerializer.new(@user).as_json
      end

      def create
        user = User.new(user_params)

        if user.save
          AuditEvent.record!(action: :created, actor: current_user, subject: user)
          render json: UserSerializer.new(user).as_json, status: :created
        else
          unprocessable(user)
        end
      end

      def update
        previous_role = @user.role

        if @user.update(user_params)
          AuditEvent.record!(action: action_for_update(previous_role), actor: current_user,
                             subject: @user, details: AuditEvent.changes_worth_recording(@user))
          render json: UserSerializer.new(@user).as_json
        else
          unprocessable(@user)
        end
      end

      def destroy
        if @user.destroy
          AuditEvent.record!(action: :deleted, actor: current_user, subject: @user)
          head :no_content
        else
          unprocessable(@user)
        end
      end

      private

      def set_user
        @user = User.find(params.expect(:id))
      end

      def user_params
        params.expect(user: %i[full_name email_address role locale avatar_url password])
      end

      def filtered_users
        User.search(params[:query]).with_role(params[:role]).ordered
      end

      def action_for_update(previous_role)
        return :updated if @user.role == previous_role

        @user.admin? ? :promoted : :demoted
      end
    end
  end
end
