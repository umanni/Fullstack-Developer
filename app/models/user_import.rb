class UserImport < ApplicationRecord
  STATUSES = { pending: 0, processing: 1, completed: 2, failed: 3 }.freeze

  belongs_to :created_by, class_name: "User"
  has_one_attached :spreadsheet

  enum :status, STATUSES, validate: true

  validates :spreadsheet, presence: true, on: :create
  validate :acceptable_spreadsheet, on: :create

  after_create_commit :enqueue_processing
  after_update_commit :broadcast_progress

  def progress_percent
    return 0 if total_rows.to_i.zero?

    ((processed_rows.to_f / total_rows) * 100).round
  end

  def finished?
    completed? || failed?
  end

  private

  def acceptable_spreadsheet
    return unless spreadsheet.attached?

    allowed = %w[
      text/csv
      application/vnd.ms-excel
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      application/csv
    ]

    content_type = spreadsheet.blob.content_type
    filename = spreadsheet.blob.filename.to_s.downcase

    unless content_type.in?(allowed) || filename.end_with?(".csv", ".xlsx", ".xls")
      errors.add(:spreadsheet, "must be a .csv or .xlsx file")
    end

    if spreadsheet.blob.byte_size > 10.megabytes
      errors.add(:spreadsheet, "must be smaller than 10MB")
    end
  end

  def enqueue_processing
    ProcessUserImportJob.perform_later(id)
  end

  def broadcast_progress
    broadcast_replace_to(
      "admin_imports",
      target: ActionView::RecordIdentifier.dom_id(self),
      partial: "admin/imports/import",
      locals: { import: self }
    )
  end
end
