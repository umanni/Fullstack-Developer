class ProcessUserImportJob < ApplicationJob
  queue_as :default

  discard_on ActiveJob::DeserializationError

  def perform(user_import_id)
    user_import = UserImport.find_by(id: user_import_id)
    return unless user_import
    return if user_import.finished?

    Users::Importer.call(user_import)
  end
end
