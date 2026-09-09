class UserImportChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user&.admin?
    import = UserImport.find(params[:id])
    stream_for import
  end
end
