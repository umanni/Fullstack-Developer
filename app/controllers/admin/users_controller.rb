module Admin
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show edit update destroy]

    def index
      authorize! User
      search = UserSearch.new(scope.with_attached_avatar_image, params)

      render inertia: "Admin/Users/Index", props: {
        users:   UserSerializer.collection(search.records),
        filters: search.to_props
      }
    end

    def show
      authorize! @user
      render inertia: "Admin/Users/Show", props: { user: UserSerializer.new(@user).as_json }
    end

    def new
      authorize! User
      render inertia: "Admin/Users/New", props: { roles: User.roles.keys }
    end

    def create
      authorize! User
      user = User.new(permitted_params(User.new, :user))

      if user.save
        redirect_to admin_users_path, notice: "#{user.full_name} was created."
      else
        redirect_to new_admin_user_path, inertia: { errors: user.errors }
      end
    end

    def edit
      authorize! @user
      render inertia: "Admin/Users/Edit", props: {
        user:  UserSerializer.new(@user).as_json,
        roles: User.roles.keys
      }
    end

    def update
      authorize! @user

      if @user.update(permitted_params(@user, :user))
        redirect_to admin_users_path, notice: "#{@user.full_name} was updated."
      else
        redirect_to edit_admin_user_path(@user), inertia: { errors: @user.errors }
      end
    end

    def destroy
      authorize! @user
      @user.destroy!
      redirect_to admin_users_path, notice: "User deleted."
    rescue ActiveRecord::RecordNotDestroyed
      redirect_to admin_users_path, alert: @user.errors.full_messages.to_sentence
    end

    private

    def scope = policy_for(User).scope

    def set_user = @user = scope.find(params[:id])
  end
end
