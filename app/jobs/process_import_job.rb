class ProcessImportJob < ApplicationJob
  queue_as :default

  def perform(import_id)
    import = Import.find(import_id)
    SpreadsheetUserImporter.new(import).call
  end
end
