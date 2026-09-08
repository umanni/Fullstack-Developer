class UserImport < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  validate :file_presence, on: :create
  validate :supported_file_format

  # Single intent method (progress is not spread across the app):
  # 0..1 completed share, never dividing by zero.
  def progress
    return 0.0 if total_rows.zero?

    processed_rows.fdiv(total_rows)
  end

  private

  def file_presence
    errors.add(:file, :blank) unless file.attached?
  end

  # Accepted formats are defined by the parser registry — the model does not
  # carry its own contract of formats (DRY single source).
  def supported_file_format
    return unless file.attached?

    extension = file.blob.filename.extension_with_delimiter.downcase
    return if UserImports::Parser::REGISTRY.key?(extension)

    errors.add(:file, :unsupported_format)
  end
end
