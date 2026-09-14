# app/controllers/admin/user_roles_controller.rb
module Admin
  class UserRolesController < ApplicationController
    def update
      user = policy_for(User).scope.find(params[:user_id])
      authorize! user, "toggle_role?"

      if user.update(role: user.admin? ? :member : :admin)
        redirect_back fallback_location: admin_users_path,
                      notice: "#{user.full_name} is now #{user.role}."
      else
        redirect_back fallback_location: admin_users_path,
                      alert: user.errors.full_messages.to_sentence
      end
    end
  end
end
