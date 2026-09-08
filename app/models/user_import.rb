class UserImport < ApplicationRecord
  MAX_FILE_SIZE = 10.megabytes
  SUPPORTED_EXTENSIONS = %w[csv xlsx].freeze
  SUPPORTED_CONTENT_TYPES = %w[
    text/csv
    text/plain
    application/csv
    application/octet-stream
    application/vnd.ms-excel
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  ].freeze

  belongs_to :uploaded_by,
    class_name: "User",
    inverse_of: :uploaded_user_imports
  has_many :rows,
    -> { order(:row_number) },
    class_name: "UserImportRow",
    dependent: :destroy,
    inverse_of: :user_import
  has_one_attached :spreadsheet

  enum :status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    completed_with_errors: "completed_with_errors",
    failed: "failed"
  }, default: :pending, validate: true

  validates :spreadsheet, presence: true
  validate :spreadsheet_is_acceptable

  def progress_percentage
    return 0 if total_rows.zero?

    ((processed_rows.to_f / total_rows) * 100).round.clamp(0, 100)
  end

  def refresh_counters!
    # `rows` has a presentation ordering scope; remove it before grouping so
    # PostgreSQL does not require row_number in the GROUP BY clause.
    counts = rows.reorder(nil).group(:status).count
    update_columns(
      processed_rows: counts.fetch("succeeded", 0) + counts.fetch("failed", 0),
      successful_rows: counts.fetch("succeeded", 0),
      failed_rows: counts.fetch("failed", 0),
      updated_at: Time.current
    )
    reload
  end

  def mark_failed!(exception)
    update!(
      status: :failed,
      failure_message: exception.message.to_s.truncate(1_000),
      finished_at: Time.current
    )
    broadcast_progress!
  end

  def broadcast_progress!
    ImportProgressChannel.broadcast_to(self, UserImportPresenter.new(self).as_json)
  end

  private
    def spreadsheet_is_acceptable
      return unless spreadsheet.attached?

      extension = spreadsheet.filename.extension_without_delimiter.downcase
      unless extension.in?(SUPPORTED_EXTENSIONS) && spreadsheet.blob.content_type.in?(SUPPORTED_CONTENT_TYPES)
        errors.add(:spreadsheet, "must be a CSV or XLSX file")
      end

      if spreadsheet.blob.byte_size > MAX_FILE_SIZE
        errors.add(:spreadsheet, "must be smaller than 10 MB")
      end
    end
end
