class SpreadsheetImport < ApplicationRecord
  ALLOWED_EXTENSIONS = %w[.csv .xlsx].freeze
  MAX_BYTES = 10.megabytes

  belongs_to :user
  has_one_attached :file
  has_many :spreadsheet_import_row_errors, dependent: :destroy

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  validate :file_must_be_a_supported_spreadsheet, on: :create

  after_commit :enqueue_import_job, on: :create
  after_commit :broadcast_progress, if: -> { saved_change_to_status? || saved_change_to_total_rows? }

  def progress_percent
    return 0 if total_rows.zero?
    ((processed_rows.to_f / total_rows) * 100).round
  end

  # Per-row progress ticks bypass callbacks entirely (see SpreadsheetImportJob,
  # which uses update_columns for those) so this is called explicitly, throttled,
  # instead of firing on every single row.
  def broadcast_progress
    Turbo::StreamsChannel.broadcast_replace_to(
      "spreadsheet_import_#{id}",
      target: "spreadsheet_import_progress",
      partial: "admin/spreadsheet_imports/progress",
      locals: { spreadsheet_import: self }
    )
  end

  private
    def file_must_be_a_supported_spreadsheet
      unless file.attached?
        errors.add(:file, "precisa ser enviada")
        return
      end

      errors.add(:file, "deve ser um arquivo CSV ou XLSX") unless File.extname(file.filename.to_s).downcase.in?(ALLOWED_EXTENSIONS)
      errors.add(:file, "é muito grande (máx #{MAX_BYTES / 1.megabyte}MB)") if file.byte_size > MAX_BYTES
    end

    def enqueue_import_job
      SpreadsheetImportJob.perform_later(id)
    end
end
