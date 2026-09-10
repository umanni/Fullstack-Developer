class UserImportChannel < ApplicationCable::Channel
  def subscribed
    return reject unless current_user&.admin?

    import = UserImport.find_by(id: params[:id])
    return reject unless import

    stream_for import
  end
end
