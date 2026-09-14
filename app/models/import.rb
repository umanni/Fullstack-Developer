class Import < ApplicationRecord
  MAX_FILE_SIZE     = 10.megabytes
  MAX_REPORTED_ROWS = 500
  CONTENT_TYPES = {
    "text/csv" => :csv,
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" => :xlsx
  }.freeze

  belongs_to :user
  has_one_attached :file

  enum :status, {
    pending: 0, parsing: 1, processing: 2,
    completed: 3, failed: 4, cancelled: 5
  }, default: :pending, validate: true

  validates :file, presence: true
  validate  :acceptable_file

  scope :recent, -> { order(created_at: :desc) }

  def format
    CONTENT_TYPES.fetch(file.content_type, :csv)
  end

  def progress
    return 0 if total_rows.zero?

    ((processed_rows.to_f / total_rows) * 100).round
  end

  def finished? = completed? || failed? || cancelled?

  def record_error(index, identifier, messages)
    return if error_report.size >= MAX_REPORTED_ROWS

    error_report << { row: index, identifier: identifier, errors: Array(messages) }
  end

  private

  def acceptable_file
    return unless file.attached?

    errors.add(:file, "must be a .csv or .xlsx file") unless CONTENT_TYPES.key?(file.content_type)
    errors.add(:file, "must be smaller than 10 MB") if file.byte_size > MAX_FILE_SIZE
  end
end
