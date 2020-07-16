module Api
  module V1
    class UsersController < Api::V1::ApiController
      before_action :authenticate_user, only: %i[current update index destroy update_password]
      before_action :set_user, only: %i[show update destroy]
      before_action :set_user_valid?, only: %i[update_password]
      load_and_authorize_resource except: %i[create import]

      def create
        save_user || render_error
      end

      def update
        update_user || render_error
      end

      # def show
      #   render json: @user
      # end

      def destroy
        destroy_user || render_error
      end

      def index 
        render json: User.all
      end

      def current
        render json: ActiveModelSerializers::SerializableResource.new(
          current_user, 
          each_serializer: Api::V1::CurrentUserSerializer
        )
      end

      def update_password
        begin
          if @user.authenticate(params[:password])
            @user.update(password: params[:new_password])
            render json: {user: @user, success: "User #{@user.full_name} successfully change password!"}, status: :created
          else
            render json: { errors: 'Check your current password!' }, status: :unprocessable_entity
          end
        rescue 
          render json: { errors: "User not found!" }, status: :forbidden
        end
      end

      private

      def save_user
        @user = User.new(user_params)
        @user.save && render(json: @user, status: :created)
      end

      def update_user
        if @user.update(user_params)
          render(json: @user)
        end
      end

      def user_params
        params.require(:user).permit(:full_name, :email, :avatar_image, :role, :password, :password_confirmation)
      end

      def render_error
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end

      def destroy_user
        @user.destroy && render(json: { 
          user: @user, 
          success: "User #{@user.full_name} successfully deleted" 
        },status: :no_content)
      end

      def set_user_valid?
        if params[:email].blank?
          render json: {errors: 'Email not informed!'}, status: :unprocessable_entity
        end
        @user = User.find_by(email: params[:email])
      end

      def set_user
        @user = User.find(params[:id])
      end
    end
  end
end
