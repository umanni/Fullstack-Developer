module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[ show edit update destroy toggle_role remove_avatar ]

    def index
      users = User.with_attached_avatar_image.order(:full_name).map do |u|
        u.as_json(only: [ :id, :full_name, :email, :role ]).merge(
          avatar_url: u.avatar_url,
          avatar_image_url: (url_for(u.avatar_image) if u.avatar_image.attached?),
          has_avatar: (u.avatar_image.attached? || u.avatar_url.present?)
        )
      end
      render inertia: "Admin/Users/Index", props: { users: users, admin_count: User.admin.count }
    end

    def show
      render inertia: "Admin/Users/Show", props: { user: user_json(@user) }
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
      render inertia: "Admin/Users/Edit", props: { user: user_json(@user) }
    end

    def update
      if @user.avatar_image.attached? && params[:user][:avatar_url].present?
        @user.avatar_image.purge
      end
      if @user.avatar_url.present? && params[:user][:avatar_image].is_a?(ActionDispatch::Http::UploadedFile)
        @user.update!(avatar_url: nil)
      end
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User updated."
      else
        render inertia: "Admin/Users/Edit", props: { user: user_json(@user) }, status: :unprocessable_entity
      end
    end

    def destroy
      if @user.admin? && User.admin.count == 1
        redirect_to admin_users_path, status: :see_other, alert: "Cannot delete the only admin on the system."
        return
      end
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

      def user_json(user)
        { id: user.id, full_name: user.full_name, email: user.email, role: user.role, avatar_url: user.avatar_url,
          avatar_attached: user.avatar_image.attached?,
          avatar_image_url: (url_for(user.avatar_image) if user.avatar_image.attached?) }
      end
  end
end
