class ImportProgressChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user.admin?

    user_import = UserImport.find_by(id: params[:id])
    reject unless user_import
    stream_for user_import
  end
end
