module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[ edit update destroy toggle_role ]

    def index
      render inertia: "Admin/Users/Index", props: {
        users: User.order(:full_name).as_json(only: [ :id, :full_name, :email, :role ])
      }
    end

    def new
      @user = User.new
      render inertia: "Admin/Users/New"
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_users_path, notice: "User created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      render inertia: "Admin/Users/Edit", props: { user: @user.as_json(only: [ :id, :full_name, :email, :role, :avatar_url ]) }
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, status: :see_other, notice: "User deleted."
    end

    def toggle_role
      @user.admin? ? @user.update!(role: :user) : @user.update!(role: :admin)
      redirect_to admin_users_path, notice: "Role updated."
    end

    private
      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.expect(user: [ :full_name, :email, :password, :password_confirmation, :role, :avatar_image, :avatar_url ])
      end
  end
end
