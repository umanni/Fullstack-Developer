module Imports
  class ProcessJob < ApplicationJob
    queue_as :imports

    retry_on StandardError, wait: :polynomially_longer, attempts: 3
    discard_on ActiveRecord::RecordNotFound

    after_discard do |job, error|
      user_import = job.arguments.first
      next unless user_import&.persisted?

      user_import.update!(
        status: :failed,
        failure_message: "Unexpected processing failure: #{error.message}".truncate(500),
        finished_at: Time.current
      )
      ProgressBroadcaster.call(user_import)
    end

    def perform(user_import)
      return if user_import.terminal?

      rows = SpreadsheetParser.call(user_import)
      user_import.update!(
        status: :processing,
        total_rows: rows.length,
        started_at: user_import.started_at || Time.current,
        failure_message: nil
      )
      ProgressBroadcaster.call(user_import)

      rows.each_with_index do |parsed_row, index|
        import_row = user_import.rows.find_or_initialize_by(row_number: parsed_row.number)
        import_row.payload = parsed_row.attributes
        import_row.save!
        RowProcessor.call(import_row) unless import_row.succeeded?
        ProgressUpdater.call(user_import)
        Dashboard::BroadcastStatsJob.perform_later if ((index + 1) % 25).zero?
      end

      finalize(user_import)
    rescue SpreadsheetParser::Error => error
      user_import.update!(status: :failed, failure_message: error.message.truncate(500), finished_at: Time.current)
      ProgressBroadcaster.call(user_import)
    end

    private
      def finalize(user_import)
        user_import.reload
        final_status = user_import.failed_rows.positive? ? :completed_with_errors : :completed
        user_import.update!(status: final_status, finished_at: Time.current)
        ProgressBroadcaster.call(user_import)
        Dashboard::BroadcastStatsJob.perform_later
      end
  end
end
