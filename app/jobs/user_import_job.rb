class UserImportJob < ApplicationJob
  queue_as :default

  def perform(file_path, progress_id)
    spreadsheet = Roo::Spreadsheet.open(file_path)
    header = spreadsheet.row(1)
    total = spreadsheet.last_row - 1

    progress = ImportProgress.find(progress_id)
    progress.update!(total: total, processed: 0, status: "running")

    (2..spreadsheet.last_row).each do |i|
      row_data = Hash[[ header, spreadsheet.row(i) ].transpose]
      user = User.new(username: row_data["username"], email: row_data["email"], password: row_data["password"])

      if user.save
        progress.increment!(:processed)
      else
        Rails.logger.error("Erro na linha #{i}: #{user.errors.full_messages.join(', ')}")
      end
    end

    progress.update!(status: "completed")
  rescue => e
      # progress may be nil if it wasn't found/created; use safe navigation
      progress&.update!(status: "failed")
    Rails.logger.error("Falha na importação: #{e.message}")
  end
end
