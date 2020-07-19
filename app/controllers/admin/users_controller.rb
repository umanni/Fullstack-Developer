class Admin::UsersController < AdminController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_collections, only: [:new, :create, :edit, :update]

  # GET /users
  def index
    @users = User.all.paginate(page: params[:page])
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_user_path(@user), notice: 'User was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def set_collections
      @user_roles = User.roles.map { |role| [t(role[0], scope: 'activerecord.attributes.user.roles'), role[0]] }
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(
        :full_name,
        :email,
        :password,
        :password_confirmation,
        :role,
        :avatar,
        :avatar_url)
    end
end
