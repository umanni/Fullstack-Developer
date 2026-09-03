module Imports
  class ProgressUpdater
    def self.call(user_import)
      counts = user_import.rows.group(:status).count
      succeeded = counts.fetch("succeeded", 0)
      failed = counts.fetch("failed", 0)

      user_import.update!(
        processed_rows: succeeded + failed,
        succeeded_rows: succeeded,
        failed_rows: failed
      )

      ProgressBroadcaster.call(user_import)
      user_import
    end
  end
end
