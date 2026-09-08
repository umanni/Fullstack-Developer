class UserImportPresenter
  def initialize(user_import, include_errors: false)
    @user_import = user_import
    @include_errors = include_errors
  end

  def as_json
    {
      id: user_import.id,
      status: user_import.status,
      file_name: user_import.spreadsheet.attached? ? user_import.spreadsheet.filename.to_s : nil,
      total_rows: user_import.total_rows,
      processed_rows: user_import.processed_rows,
      successful_rows: user_import.successful_rows,
      failed_rows: user_import.failed_rows,
      progress_percentage: user_import.progress_percentage,
      failure_message: user_import.failure_message,
      uploaded_by: user_import.uploaded_by.full_name,
      created_at: user_import.created_at.iso8601,
      started_at: user_import.started_at&.iso8601,
      finished_at: user_import.finished_at&.iso8601,
      row_errors: row_errors
    }
  end

  private
    attr_reader :user_import, :include_errors

    def row_errors
      return [] unless include_errors

      user_import.rows.failed.limit(100).pluck(:row_number, :payload, :error_message).map do |row_number, payload, message|
        { row_number:, email: payload["email"], message: }
      end
    end
end
