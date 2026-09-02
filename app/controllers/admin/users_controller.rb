module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[ edit update destroy toggle_role ]

    def index
      @search = Users::Search.call(query: params[:query], page: params[:page])
    end

    def new
      @user = User.new(role: :user)
    end

    def create
      @user = Users::Create.call(attributes: user_params, invite: true)

      if @user.persisted?
        redirect_to admin_users_path, notice: "User created. Password setup instructions were queued."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @user = Users::Update.call(user: @user, attributes: user_params)

      if @user.errors.empty?
        redirect_to admin_users_path, notice: "User updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      user = Users::Destroy.call(user: @user)

      if user.destroyed?
        if user == Current.user
          terminate_session
          redirect_to root_path, notice: "Your account was deleted.", status: :see_other
        else
          redirect_to admin_users_path, notice: "User deleted.", status: :see_other
        end
      else
        redirect_to admin_users_path, alert: user.errors.full_messages.to_sentence
      end
    end

    def toggle_role
      user = Users::ToggleRole.call(user: @user)

      if user.errors.empty?
        destination = user == Current.user && user.user? ? profile_path : admin_users_path
        redirect_to destination, notice: "Role changed to #{user.role}."
      else
        redirect_to admin_users_path, alert: user.errors.full_messages.to_sentence
      end
    end

    private
      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.expect(user: %i[ full_name email avatar_image avatar_image_url ])
      end
  end
end
