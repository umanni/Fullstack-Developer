class SpreadsheetImportRowError < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :spreadsheet_import

  validates :row_number, presence: true
  validates :message, presence: true

  after_create_commit :broadcast_append

  private
    # Appends just this row instead of the whole progress partial re-rendering
    # every error every time — O(1) per error instead of O(errors so far).
    def broadcast_append
      Turbo::StreamsChannel.broadcast_append_to(
        "spreadsheet_import_#{spreadsheet_import_id}",
        target: dom_id(spreadsheet_import, :row_errors),
        partial: "admin/spreadsheet_imports/row_error",
        locals: { row_error: self }
      )
    end
end
