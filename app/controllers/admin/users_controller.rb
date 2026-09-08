module Admin
  class UsersController < BaseController
    include Pagy::Method

    before_action :set_user, only: %i[ edit update destroy toggle_role ]

    def index
      scope = User.search(params[:query]).alphabetical
      scope = scope.where(role: params[:role]) if User.roles.key?(params[:role])
      pagy, users = pagy(:offset, scope.with_attached_avatar_image, limit: 12)

      render inertia: "Admin/Users/Index", props: {
        users: users.map { |user| UserPresenter.new(user).as_json },
        pagination: {
          page: pagy.page,
          pages: pagy.pages,
          count: pagy.count,
          limit: pagy.limit,
          previous: pagy.previous,
          next: pagy.next
        },
        filters: { query: params[:query].to_s, role: params[:role].to_s }
      }
    end

    def new
      render inertia: "Admin/Users/New"
    end

    def create
      user = User.new(create_user_params)

      if user.save
        redirect_to admin_users_path, notice: "User created successfully."
      else
        redirect_to new_admin_user_path, inertia: { errors: user.errors }
      end
    end

    def edit
      render inertia: "Admin/Users/Edit", props: {
        user: UserPresenter.new(@user).as_json
      }
    end

    def update
      attributes = update_user_params
      remove_blank_password!(attributes)
      remove_avatar = ActiveModel::Type::Boolean.new.cast(attributes.delete(:remove_avatar))

      if @user.update(attributes)
        @user.avatar_image.purge if remove_avatar
        redirect_to admin_users_path, notice: "User updated successfully."
      else
        redirect_to edit_admin_user_path(@user), inertia: { errors: @user.errors }
      end
    end

    def destroy
      Users::Destroyer.call(user: @user, actor: Current.user)
      redirect_to admin_users_path, status: :see_other, notice: "User deleted successfully."
    rescue Users::Destroyer::Error => error
      redirect_to admin_users_path, status: :see_other, alert: error.message
    end

    def toggle_role
      Users::RoleChanger.call(user: @user, actor: Current.user)
      redirect_to admin_users_path, status: :see_other, notice: "User role updated successfully."
    rescue Users::RoleChanger::Error => error
      redirect_to admin_users_path, status: :see_other, alert: error.message
    end

    private
      def set_user
        @user = User.find(params[:id])
      end

      def create_user_params
        params.expect(user: %i[full_name email role password password_confirmation avatar_image])
      end

      def update_user_params
        params.expect(user: %i[full_name email password password_confirmation avatar_image remove_avatar])
      end
  end
end
