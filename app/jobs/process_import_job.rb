class ProcessImportJob < ApplicationJob
  include ActiveJob::Continuable

  BATCH_SIZE = 100

  queue_as :imports
  retry_on Imports::RowSet::MalformedFile, attempts: 1
  discard_on ActiveJob::DeserializationError

  def perform(import)
    @import = import
    return if @import.finished?

    step :count_rows
    step :import_rows, start: 0
    step :finalize
  end

  private

  attr_reader :import

  def count_rows
    import.update!(status: :parsing, started_at: Time.current)

    download { |path| import.update!(total_rows: Imports::RowSet.for(import, path).count) }

    import.update!(status: :processing)
    Imports::ProgressBroadcaster.call(import)
  rescue Imports::RowSet::MalformedFile => error
    fail_with(error.message)
    raise
  end

  def import_rows(step)
    importer = Imports::UserImporter.new
    tally    = Hash.new(0)

    download do |path|
      DashboardBroadcasts.suppress do
        Imports::RowSet.for(import, path).each do |index, row|
          next if index <= step.cursor

          apply(importer, index, row, tally)

          if index % BATCH_SIZE == 0
            flush(tally, index)
            step.set! index
          end
        end
      end
    end

    flush(tally, import.total_rows)
    step.set! import.total_rows
  end

  def finalize
    import.update!(status: :completed, finished_at: Time.current)
    Dashboard::Broadcaster.call
    Imports::ProgressBroadcaster.call(import)
  end

  def apply(importer, index, row, tally)
    result = importer.call(row)

    case result.outcome
    when :created then tally[:created_count] += 1
    when :skipped then tally[:skipped_count] += 1
    when :failed
      tally[:failed_count] += 1
      import.record_error(index, row.email_address, result.errors)
    end
  end

  def flush(tally, processed)
    return if tally.empty? && import.processed_rows == processed

    import.update_columns(
      processed_rows: processed,
      created_count:  import.created_count + tally[:created_count],
      skipped_count:  import.skipped_count + tally[:skipped_count],
      failed_count:   import.failed_count + tally[:failed_count],
      error_report:   import.error_report,
      updated_at:     Time.current
    )
    tally.clear
    Imports::ProgressBroadcaster.call(import)
  end

  def download(&)
    import.file.open(tmpdir: Dir.tmpdir, &)
  end

  def fail_with(reason)
    import.update!(status: :failed, failure_reason: reason, finished_at: Time.current)
    Imports::ProgressBroadcaster.call(import)
  end
end
