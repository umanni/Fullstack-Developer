module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[ edit update destroy toggle_role ]

    def index
      users = User.with_attached_avatar_image.order(:full_name).map do |u|
        u.as_json(only: [ :id, :full_name, :email, :role ]).merge(
          avatar_url: u.avatar_url,
          avatar_image_url: (url_for(u.avatar_image) if u.avatar_image.attached?),
          has_avatar: (u.avatar_image.attached? || u.avatar_url.present?)
        )
      end
      render inertia: "Admin/Users/Index", props: { users: users }
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
        render inertia: "Admin/Users/New", status: :unprocessable_entity
      end
    end

    def edit
      render inertia: "Admin/Users/Edit", props: { user: @user.as_json(only: [ :id, :full_name, :email, :role, :avatar_url ]) }
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User updated."
      else
        render inertia: "Admin/Users/Edit", props: { user: @user.as_json(only: [ :id, :full_name, :email, :role, :avatar_url ]) }, status: :unprocessable_entity
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

    def remove_avatar
      @user = User.find(params[:id])
      @user.avatar_image.purge
      @user.update!(avatar_url: nil)
      redirect_to admin_users_path, notice: "Avatar removed."
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
