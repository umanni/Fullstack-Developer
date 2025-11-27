class UserImport < ApplicationRecord
  # Associations
  belongs_to :user
  has_one_attached :spreadsheet_file

  # Enums
  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  # Validations
  validates :spreadsheet_file, presence: true
  validate :validate_spreadsheet_file_type

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  # Instance methods
  def progress_percentage
    return 0 if total_rows.nil? || total_rows.zero?

    ((processed_rows.to_f / total_rows) * 100).round(2)
  end

  def finished?
    completed? || failed?
  end

  private

  def validate_spreadsheet_file_type
    return unless spreadsheet_file.attached?

    allowed_types = %w[
      application/vnd.ms-excel
      application/excel
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      text/csv
      application/csv
    ]

    content_type = spreadsheet_file.blob.content_type
    return if allowed_types.include?(content_type)

    errors.add(:spreadsheet_file, 'must be a valid Excel or CSV file')
  end
end

