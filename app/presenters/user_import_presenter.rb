# frozen_string_literal: true

# Pure presentation of a UserImport for Inertia (SRP — no business rule):
# date formatting, status label and rounded percentage come from the model's
# single progress intent. Contract mirrored by AdminImport in the TS types.
class UserImportPresenter
  def initialize(user_import)
    @user_import = user_import
  end

  def to_inertia
    {
      id: id,
      file_name: file_name,
      status: status,
      status_human: status_human,
      total_rows: total_rows,
      processed_rows: processed_rows,
      failed_rows: failed_rows,
      progress: percent,
      finished_at: finished_at,
      error_message: error_message,
      created_at: created_at
    }
  end

  private

  attr_reader :user_import

  delegate :id, :status, :total_rows, :processed_rows, :failed_rows, :error_message, to: :user_import

  def file_name
    user_import.file.attached? ? user_import.file.filename.to_s : nil
  end

  def status_human
    status&.capitalize
  end

  def percent
    (user_import.progress * 100).round
  end

  def finished_at
    user_import.finished_at&.iso8601
  end

  def created_at
    user_import.created_at&.iso8601
  end
end
