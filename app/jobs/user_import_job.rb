class UserImportJob < ApplicationJob
  queue_as :default

  def perform(user_import_id)
    Rails.logger.info("=" * 50)
    Rails.logger.info("UserImportJob started for import ##{user_import_id}")
    Rails.logger.info("=" * 50)
    
    user_import = UserImport.find(user_import_id)
    Rails.logger.info("UserImport found: #{user_import.inspect}")
    Rails.logger.info("File attached: #{user_import.spreadsheet_file.attached?}")
    
    if user_import.spreadsheet_file.attached?
      Rails.logger.info("File content_type: #{user_import.spreadsheet_file.blob.content_type}")
      Rails.logger.info("File filename: #{user_import.spreadsheet_file.blob.filename}")
      Rails.logger.info("File byte_size: #{user_import.spreadsheet_file.blob.byte_size}")
    end
    
    service = UserImports::CreateService.new(user_import)
    service.call
    
    Rails.logger.info("UserImportJob completed for import ##{user_import_id}")
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("UserImport #{user_import_id} not found: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Error processing UserImport #{user_import_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    user_import&.update(status: :failed)
  end
end

