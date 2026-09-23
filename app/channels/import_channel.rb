class ImportChannel < ApplicationCable::Channel
  def subscribed
    import = Import.find(params[:id])
    reject unless current_user&.admin? || import.user_id == current_user&.id
    stream_for import
  end
end
