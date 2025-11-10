class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def dashboard
    @total_users = User.count
    @total_admins = User.admin.count
    @total_no_admins = User.no_admin.count
    @pagy, @records = pagy(:offset, User.order(:full_name), limit: 10)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_dashboard_url, notice: t("messages.user_create_success")
    else
      render "new"
    end
  end

  def edit
    @roles_options = User.roles.keys
    set_user
  end

  def update
    set_user

    if @user.admin? && User.admin.count == 1 && user_params[:role] == "no_admin"
      flash.now[:alert] = t("messages.errors.update_last_admin_to_no_admin")
      @roles_options = User.roles.keys
      render "edit"
    elsif @user.update(user_params)
        redirect_to admin_dashboard_url, notice: t("messages.update_user_success"), status: :see_other
    else
      @roles_options = User.roles.keys
      render "edit"
    end
  end

  def destroy
    set_user

    if @user.admin? && User.admin.count == 1
      redirect_to admin_dashboard_url, alert: t("messages.destroy_user_last_admin"), status: :see_other
    else
      @user.destroy!
      redirect_to admin_dashboard_url, notice: t("messages.destroy_user_success"), status: :see_other
    end
  end

  def import
    file = params[:file]

    return redirect_to admin_dashboard_url, alert: t("messages.errors.upload_csv.no_file_selected") unless file
    return redirect_to admin_dashboard_url, alert: t("messages.errors.upload_csv.content_type") unless file.content_type == "text/csv"

    csv = CsvImportService.new(file)
    csv.import_users
    redirect_to admin_dashboard_url, notice: t("messages.users_successfully_uploaded", count: csv.number_imported_with_last_run)
  end

  private

  def check_admin
    unless current_user.admin?
      redirect_to root_url, alert: t("messages.errors.restricted_area")
    end
  end

  def user_params
    params.expect(user: [ :full_name, :id, :email, :avatar_image, :role ])
  end

  def set_user
    @user = User.find(params[:id])
  end
end
