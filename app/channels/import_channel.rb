class ImportChannel < ApplicationCable::Channel
  def subscribed
    import = Import.find_by(id: params[:id])
    return reject unless import && current_user&.admin?

    stream_from Imports::ProgressBroadcaster.stream_for(import)
  end
end
