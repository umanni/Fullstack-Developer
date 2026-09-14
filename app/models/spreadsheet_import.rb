class SpreadsheetImport < ApplicationRecord
  # Validated by extension rather than by content type: Marcel reports a CSV as
  # text/plain, and Roo picks its parser from the extension anyway.
  ALLOWED_EXTENSIONS = %w[ csv xlsx ].freeze
  MAX_FILE_SIZE = 5.megabytes

  belongs_to :user
  has_one_attached :file

  enum :status,
       { pending: "pending", processing: "processing", completed: "completed", failed: "failed" },
       default: :pending, validate: true

  # On create only: the file is attached once and never replaced, and re-running this
  # on every update would block the job from recording a failure on an unreadable file
  # — the exact moment the status matters most.
  validate :file_must_be_a_spreadsheet, on: :create

  scope :recent_first, -> { order(created_at: :desc) }

  def progress
    return 0 if total_rows.zero?

    processed_rows * 100 / total_rows
  end

  def imported_rows
    processed_rows - failed_rows
  end

  def unlisted_failures
    failed_rows - row_errors.size
  end

  private
    def file_must_be_a_spreadsheet
      return errors.add(:file, "must be attached") unless file.attached?

      unless file.filename.extension_without_delimiter.downcase.in?(ALLOWED_EXTENSIONS)
        errors.add(:file, "must be a .csv or .xlsx file")
      end

      errors.add(:file, "is empty") if file.byte_size.zero?

      errors.add(:file, "must be under #{MAX_FILE_SIZE / 1.megabyte} MB") if file.byte_size > MAX_FILE_SIZE
    end
end
