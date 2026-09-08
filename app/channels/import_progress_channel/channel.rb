# frozen_string_literal: true

module ImportProgressChannel
  class Channel < ApplicationCable::Channel
    def subscribed
      import = UserImport.find_by(id: params[:import_id])
      return reject unless import && Users::Policy.admin?(current_user)

      stream_for import
    end
  end
end
