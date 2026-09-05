class SpreadsheetImportJob < ApplicationJob
  queue_as :default

  # Broadcasting progress on every single row floods Turbo Streams/Solid Cable on
  # large imports (one full partial render + DB write per row); broadcast at most
  # every Nth row instead. The final state is always covered separately by the
  # status: :completed/:failed transition below (a regular update!, so it
  # broadcasts on its own) — forcing an extra broadcast on the very last row here
  # too would just double up with that one, back to back.
  PROGRESS_BROADCAST_INTERVAL = 10

  def perform(spreadsheet_import_id)
    import = SpreadsheetImport.find_by(id: spreadsheet_import_id)
    return unless import&.pending?

    import.update!(status: :processing)

    rows = SpreadsheetParser.new(import).rows
    import.update!(total_rows: rows.size)

    row_importer = SpreadsheetImportRowImporter.new(import)
    users_created = 0

    rows.each_with_index do |(row_number, data), index|
      users_created += 1 if row_importer.import(row_number, data)
      import.update_columns(processed_rows: index + 1)
      import.broadcast_progress if ((index + 1) % PROGRESS_BROADCAST_INTERVAL).zero?
    end

    User.broadcast_dashboard_counts! if users_created.positive?
    import.update!(status: :completed)
  rescue => e
    Rails.logger.warn("SpreadsheetImportJob: failed to process import #{spreadsheet_import_id}: #{e.message}")
    import&.update!(status: :failed)
  end
end
