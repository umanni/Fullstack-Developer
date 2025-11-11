class ImportProgressChannel < ApplicationCable::Channel
  def subscribed
    return reject unless current_user&.admin?
    return reject unless params[:import_id].present?

    import = Import.find_by(id: params[:import_id])
    return reject unless import

    stream_from "import_#{import.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
