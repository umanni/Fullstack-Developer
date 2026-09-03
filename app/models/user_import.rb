class UserImport < ApplicationRecord
  MAX_FILE_SIZE = 5.megabytes
  CONTENT_TYPES_BY_EXTENSION = {
    ".csv" => %w[text/csv application/csv application/vnd.ms-excel].freeze,
    ".xlsx" => %w[application/vnd.openxmlformats-officedocument.spreadsheetml.sheet].freeze
  }.freeze

  belongs_to :created_by, class_name: "User", inverse_of: :created_imports, optional: true
  has_many :rows, class_name: "UserImportRow", dependent: :destroy, inverse_of: :user_import
  has_one_attached :spreadsheet

  enum :status, {
    queued: 0,
    processing: 1,
    completed: 2,
    completed_with_errors: 3,
    failed: 4
  }, default: :queued, validate: true

  validates :spreadsheet, presence: true
  validates :created_by, presence: true, on: :create
  validate :spreadsheet_is_supported

  scope :recent_first, -> { order(created_at: :desc) }

  def progress_percentage
    return 0 if total_rows.zero?

    ((processed_rows.to_f / total_rows) * 100).round.clamp(0, 100)
  end

  def terminal?
    completed? || completed_with_errors? || failed?
  end

  private
    def spreadsheet_is_supported
      return unless spreadsheet.attached?

      extension = File.extname(spreadsheet.filename.to_s).downcase
      supported_content_types = CONTENT_TYPES_BY_EXTENSION[extension]
      errors.add(:spreadsheet, "must be a CSV or XLSX file") unless supported_content_types
      unless supported_content_types&.include?(spreadsheet.blob.content_type)
        errors.add(:spreadsheet, "content type does not match its extension")
      end
      errors.add(:spreadsheet, "must be smaller than 5 MB") if spreadsheet.blob.byte_size > MAX_FILE_SIZE
    end
end
