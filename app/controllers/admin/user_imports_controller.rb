class Admin::UserImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def create
    file = params[:file]
    return unless validate_import_file(file)

    CsvImportUsersService.new.call(file)
    redirect_to admin_users_path(page: params[:page]), notice: "File imported successfully."
  end
end

private

ALLOWED_CONTENT_TYPES = [ "text/csv" ].freeze

  def validate_import_file(file)
    if file.blank?
      redirect_to admin_users_path(page: params[:page]), alert: "Please choose a file to upload."
      return false
    end

    unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
      redirect_to admin_users_path(page: params[:page]), alert: "Ivalid type file (only CSV)."
      return false
    end

    true
  end
