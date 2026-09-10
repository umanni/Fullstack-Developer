module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[ show edit update destroy toggle_role remove_avatar ]

    def index
      users = User.with_attached_avatar_image.order(:full_name).page(params[:page]).per(25)
      render inertia: "Admin/Users/Index", props: {
        users: users.map { |u|
          u.as_json(only: [ :id, :full_name, :email, :role ]).merge(
            avatar_url: u.avatar_url,
            avatar_image_url: (url_for(u.avatar_image) if u.avatar_image.attached?),
            has_avatar: (u.avatar_image.attached? || u.avatar_url.present?)
          )
        },
        admin_count: User.admin.count,
        pagination: {
          current_page: users.current_page,
          total_pages: users.total_pages,
          total_count: users.total_count
        }
      }
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
        AuditLog.log!(action: "user_created", user: Current.user, auditable: @user, request: request)
        redirect_to admin_users_path, notice: "User created."
      else
        render inertia: "Admin/Users/New", status: :unprocessable_entity
      end
    end

    def edit
      render inertia: "Admin/Users/Edit", props: { user: user_json(@user) }
    end

    def update
      if @user.update(user_params_without_stale_avatar)
        # An explicit URL wins over a stored upload; drop the now-unused file
        # only after the record is safely persisted.
        @user.avatar_image.purge if replacing_attachment_with_url?
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
      AuditLog.log!(action: "user_destroyed", user: Current.user, auditable: @user, metadata: { email: @user.email }, request: request)
      @user.destroy
      redirect_to admin_users_path, status: :see_other, notice: "User deleted."
    end

    def toggle_role
      new_role = @user.admin? ? :user : :admin
      if new_role == :user && User.admin.count <= 1
        redirect_to admin_users_path, alert: "Cannot demote the only admin on the system."
        return
      end
      old_role = @user.role
      @user.update!(role: new_role)
      AuditLog.log!(action: "role_toggled", user: Current.user, auditable: @user, metadata: { from: old_role, to: new_role }, request: request)
      redirect_to admin_users_path, notice: "Role updated to #{new_role}."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_users_path, alert: "Could not update role: #{e.record.errors.full_messages.join(', ')}"
    end

    def remove_avatar
      ActiveRecord::Base.transaction do
        @user.avatar_image.purge
        @user.update!(avatar_url: nil)
      end
      redirect_to admin_users_path, notice: "Avatar removed."
    end

    private
      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.expect(user: [ :full_name, :email, :password, :password_confirmation, :role, :avatar_image, :avatar_url ])
      end

      # A freshly uploaded file takes precedence over any URL carried in the form.
      def user_params_without_stale_avatar
        avatar_upload? ? user_params.merge(avatar_url: nil) : user_params
      end

      def avatar_upload?
        params.dig(:user, :avatar_image).is_a?(ActionDispatch::Http::UploadedFile)
      end

      def replacing_attachment_with_url?
        !avatar_upload? && user_params[:avatar_url].present? && @user.avatar_image.attached?
      end

      def user_json(user)
        { id: user.id, full_name: user.full_name, email: user.email, role: user.role, avatar_url: user.avatar_url,
          avatar_attached: user.avatar_image.attached?,
          avatar_image_url: (url_for(user.avatar_image) if user.avatar_image.attached?) }
      end
  end
end
