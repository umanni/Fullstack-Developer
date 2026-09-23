class Import < ApplicationRecord
  belongs_to :user
  has_one_attached :spreadsheet

  STATUSES = %w[pending processing completed failed].freeze

  validates :filename, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :spreadsheet, presence: true, on: :create

  after_commit :broadcast_progress, on: %i[create update]

  def progress_percent
    return 0 if total_rows.zero?

    ((processed_rows.to_f / total_rows) * 100).round
  end

  def mark_processing!(total)
    update!(status: "processing", total_rows: total, processed_rows: 0, success_count: 0, failure_count: 0)
  end

  def increment_progress!(success:)
    attrs = { processed_rows: processed_rows + 1 }
    attrs[success ? :success_count : :failure_count] = (success ? success_count : failure_count) + 1
    update!(attrs)
  end

  def mark_completed!
    update!(status: "completed")
  end

  def mark_failed!(message)
    update!(status: "failed", error_message: message)
  end

  private

  def broadcast_progress
    ImportChannel.broadcast_to(self, {
      id: id,
      status: status,
      filename: filename,
      total_rows: total_rows,
      processed_rows: processed_rows,
      success_count: success_count,
      failure_count: failure_count,
      progress_percent: progress_percent,
      error_message: error_message
    })
  end
end
