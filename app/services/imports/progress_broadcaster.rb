module Imports
  class ProgressBroadcaster
    extend ActionView::RecordIdentifier

    def self.call(user_import)
      Turbo::StreamsChannel.broadcast_replace_to(
        user_import,
        :progress,
        target: dom_id(user_import, :progress),
        partial: "admin/user_imports/progress",
        locals: {
          user_import:,
          failed_rows: user_import.rows.failed.order(:row_number).limit(100)
        }
      )
    end
  end
end
