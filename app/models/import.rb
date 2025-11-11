class Import < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  STATUSES = %w[pending processing completed failed].freeze

  validates :file_name, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  after_initialize :set_defaults, if: :new_record?

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }

  private

  def set_defaults
    self.status ||= "pending"
    self.progress ||= 0.0
    self.total_rows ||= 0
    self.processed_rows ||= 0
    self.successful_rows ||= 0
    self.failed_rows ||= 0
    self.error_details ||= ""
  end

  public

  def pending?
    status == "pending"
  end

  def processing?
    status == "processing"
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def calculate_progress
    return 0 if total_rows.zero?
    ((processed_rows.to_f / total_rows) * 100).round(2)
  end

  def update_progress!
    self.progress = calculate_progress
    save!
  end

  def add_error(error_message)
    self.error_details = error_details.to_s + "\n#{Time.current}: #{error_message}"
    save!
  end

  def success_rate
    return 0 if processed_rows.zero?
    ((successful_rows.to_f / processed_rows) * 100).round(2)
  end

  def display_status
    status.humanize
  end

  def estimated_time_remaining
    return nil unless processing? && processed_rows > 0

    elapsed_time = Time.current - updated_at
    avg_time_per_row = elapsed_time / processed_rows
    remaining_rows = total_rows - processed_rows

    (remaining_rows * avg_time_per_row).seconds
  end
end
