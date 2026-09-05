require "rails_helper"

RSpec.describe SpreadsheetImportRowError, type: :model do
  subject { build(:spreadsheet_import_row_error) }

  it { is_expected.to belong_to(:spreadsheet_import) }
  it { is_expected.to validate_presence_of(:row_number) }
  it { is_expected.to validate_presence_of(:message) }
end
