module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy toggle_role]

    def index
      @users = User.includes(:user_role, avatar_image_attachment: :blob)
                   .where.not(id: current_user.id)
                   .order(:full_name)
    end

    def show
    end

    def new
      @user = User.new(user_role: UserRole.non_admin)
      @roles = UserRole.order(:label)
    end

    def create
      @user = User.new(user_params)
      @roles = UserRole.order(:label)

      if @user.save
        redirect_to admin_user_path(@user), notice: "Usuário criado."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @roles = UserRole.order(:label)
    end

    def update
      @roles = UserRole.order(:label)

      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "Usuário atualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "Você não pode excluir a própria conta de admin aqui."
        return
      end

      @user.destroy!
      redirect_to admin_users_path, notice: "Usuário excluído.", status: :see_other
    end

    def toggle_role
      if @user == current_user
        redirect_to admin_users_path, alert: "Você não pode alterar o próprio perfil."
        return
      end

      @user.toggle_role!
      redirect_to admin_users_path, notice: "#{@user.full_name} agora é #{@user.user_role.label}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :full_name,
        :email,
        :password,
        :password_confirmation,
        :user_role_id,
        :avatar_url,
        :avatar_image
      )
    end
  end
end
