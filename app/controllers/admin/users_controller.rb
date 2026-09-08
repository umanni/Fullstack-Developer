# frozen_string_literal: true

module Admin
  # Thin controller: writes go through Admin::UserForm, reads through
  # Users::ListingQuery / UserPresenter, role rules live in Users::Policy.
  class UsersController < BaseController
    def index
      listing = Users::ListingQuery.call(
        scope: User.all,
        search: params[:search],
        page: params[:page]
      )

      render inertia: "Admin/Users/Index", props: {
        users: listing.users.map { |user| user_item(user) },
        pagination: listing.pagination,
        filters: { search: params[:search].to_s },
        urls: admin_urls.merge(new_url: new_admin_user_path)
      }
    end

    def new
      render inertia: "Admin/Users/New", props: {
        urls: admin_urls.merge(submit_url: admin_users_path, cancel_url: admin_users_path)
      }
    end

    def create
      form = Admin::UserForm.new(user_params)

      if form.save
        Dashboard::Publisher.call
        redirect_to admin_users_path, notice: "User created successfully."
      else
        render inertia: "Admin/Users/New", props: {
          urls: admin_urls.merge(submit_url: admin_users_path, cancel_url: admin_users_path),
          form: echoed_attributes,
          errors: form.errors.to_hash
        }
      end
    end

    def edit
      @user = User.find(params[:id])
      render inertia: "Admin/Users/Edit", props: {
        urls: admin_urls.merge(submit_url: admin_user_path(@user), cancel_url: admin_users_path),
        user: UserPresenter.new(@user).to_inertia,
        form: edit_attributes
      }
    end

    def update
      @user = User.find(params[:id])
      form = Admin::UserForm.new(user_params, user: @user)

      if form.update
        Dashboard::Publisher.call
        redirect_to admin_users_path, notice: "User updated successfully."
      else
        render inertia: "Admin/Users/Edit", props: {
          urls: admin_urls.merge(submit_url: admin_user_path(@user), cancel_url: admin_users_path),
          user: UserPresenter.new(@user).to_inertia,
          form: echoed_attributes,
          errors: form.errors.to_hash
        }
      end
    end

    def destroy
      target = User.find(params[:id])

      if policy.destructible?(Current.user, target)
        Users::AccountCloser.call(target)
        Dashboard::Publisher.call
        redirect_to admin_users_path, notice: "User deleted successfully."
      else
        redirect_to admin_users_path, alert: "You cannot delete this user."
      end
    end

    def toggle_role
      target = User.find(params[:id])

      if policy.demotable?(Current.user, target) && Users::RoleToggler.call(target)
        Dashboard::Publisher.call
        redirect_to admin_users_path, notice: "Role switched to #{target.role}."
      else
        redirect_to admin_users_path, alert: "You cannot change this user's role."
      end
    end

    private

    def policy
      Users::Policy.new(Current.user)
    end

    def admin_urls
      {
        dashboard_url: admin_root_path,
        users_url: admin_users_path,
        imports_url: admin_user_imports_path
      }
    end

    def user_params
      params.permit(:full_name, :email_address, :avatar, :avatar_url, :role, :password, :password_confirmation)
    end

    def user_item(user)
      UserPresenter.new(user).to_inertia.merge(
        edit_url: edit_admin_user_path(user),
        toggle_url: toggle_role_admin_user_path(user),
        delete_url: admin_user_path(user)
      )
    end

    def echoed_attributes
      params.permit(:full_name, :email_address, :avatar_url, :role).to_h
    end

    def edit_attributes
      {
        full_name: @user.full_name,
        email_address: @user.email_address,
        avatar_url: @user.avatar_url,
        role: @user.role
      }
    end
  end
end
