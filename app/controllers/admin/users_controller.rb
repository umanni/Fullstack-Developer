module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy toggle_role]

    def index
      @users = User.order(:full_name)
    end

    def show
    end

    def new
      @user = User.new(role: :member)
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_user_path(@user), notice: "User created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "User updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == Current.user
        redirect_to admin_users_path, alert: "You cannot delete your own account from the admin panel."
        return
      end

      @user.destroy!
      redirect_to admin_users_path, notice: "User deleted.", status: :see_other
    end

    def toggle_role
      if @user == Current.user
        redirect_to admin_users_path, alert: "You cannot change your own role."
        return
      end

      @user.admin? ? @user.member! : @user.admin!
      redirect_to admin_users_path, notice: "#{@user.full_name} is now #{@user.role}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :full_name,
        :email_address,
        :password,
        :password_confirmation,
        :role,
        :avatar_url,
        :avatar_image
      )
    end
  end
end
