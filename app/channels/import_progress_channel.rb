class ImportProgressChannel < ApplicationCable::Channel
  def subscribed
    return reject unless current_user&.admin?

    import_id = params[:import_id]
    stream_from "import_progress_#{import_id}" if import_id.present?
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

