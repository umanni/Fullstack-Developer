# == Schema Information
#
# Table name: user_imports
#
#  id             :bigint           not null, primary key
#  failed_rows    :integer          default(0), not null
#  file_name      :string
#  processed_rows :integer          default(0), not null
#  row_errors     :jsonb            not null
#  status         :integer          default(0), not null
#  total_rows     :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class UserImport < ApplicationRecord
  has_one_attached :file

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }, default: :pending

  validates :file, presence: true
  validate :file_size_within_limit, on: :create
  validate :file_content_type_allowed, on: :create

  def file_name
    file.attached? ? file.filename.to_s : nil
  end

  def progress_percent
    return 0 if total_rows.zero?
    ((processed_rows + failed_rows) * 100.0 / total_rows).round
  end

  private
    def file_size_within_limit
      return unless file.attached?
      if file.blob.byte_size > MAX_IMPORT_FILE_SIZE
        file.purge
        errors.add(:file, "is too large (maximum is #{MAX_IMPORT_FILE_SIZE / 1.megabyte}MB)")
      end
    end

    def file_content_type_allowed
      return unless file.attached?
      unless ALLOWED_IMPORT_CONTENT_TYPES.include?(file.content_type)
        file.purge
        errors.add(:file, "must be a CSV or Excel file (.csv, .xlsx)")
      end
    end
end
