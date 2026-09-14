class ImportSerializer
  def self.collection(imports) = imports.map { new(_1).as_json }

  def initialize(import) = @import = import

  def as_json(*)
    {
      id: @import.id,
      status: @import.status,
      filename: @import.file.filename.to_s,
      progress: @import.progress,
      total_rows: @import.total_rows,
      processed_rows: @import.processed_rows,
      created_count: @import.created_count,
      skipped_count: @import.skipped_count,
      failed_count: @import.failed_count,
      failure_reason: @import.failure_reason,
      finished: @import.finished?,
      error_report: @import.error_report.first(50),
      created_at: @import.created_at.iso8601
    }
  end
end
