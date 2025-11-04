module Admin
  class UsersController < Admin::ApplicationController
    layout "admin_custom", only: [:import_form]

    def index
      super

     
      @users_count = User.count
      @admins_count = User.admin.count
      @normal_users_count = User.user.count
    end

    def scoped_resource
      User.all
    end

    def resource_params
      params.require(:user).permit(:username, :email, :role, :password, :password_confirmation, :avatar_image)
    end

    def update_resource(resource, attributes)
      attrs = attributes.first
      if attrs[:password].blank? && attrs[:password_confirmation].blank?
        resource.update_without_password(attrs.except(:password, :password_confirmation))
      else
        resource.update(attrs)
      end
    end

    def create
      @user = User.new(resource_params)
      if @user.save
        redirect_to admin_user_path(@user), notice: translate_with_resource("create.success")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def import_form; end

    def progress
      @progress = ImportProgress.find(params[:progress_id])
    end


def import
   Rails.logger.info "Iniciando import"

  if params[:file].blank?
    redirect_to import_form_admin_users_path, alert: "Por favor, envie um arquivo."
    return
  end

  tmp_path = Rails.root.join("tmp", params[:file].original_filename)
  File.open(tmp_path, "wb") { |f| f.write(params[:file].read) }

  progress = ImportProgress.create!(status: :running, total: 0, processed: 0)
  Rails.logger.info "Progress criado: #{progress.inspect}"

  UserImportJob.perform_later(tmp_path.to_s, progress.id)

  redirect_to progress_admin_users_path(progress_id: progress.id)
end
  end
end
