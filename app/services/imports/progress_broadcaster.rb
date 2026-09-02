module Imports
  class ProgressBroadcaster
    extend ActionView::RecordIdentifier

    def self.call(user_import)
      Turbo::StreamsChannel.broadcast_replace_to(
        user_import,
        :progress,
        target: dom_id(user_import, :progress),
        partial: "admin/user_imports/progress",
        locals: { user_import: }
      )
    end
  end
end
