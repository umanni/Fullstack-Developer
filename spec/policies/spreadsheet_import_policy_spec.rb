require "rails_helper"

RSpec.describe SpreadsheetImportPolicy do
  let(:admin) { build_stubbed(:user, :admin) }
  let(:no_admin) { build_stubbed(:user) }

  context "when the user is an admin" do
    subject { described_class.new(admin, SpreadsheetImport) }

    it { is_expected.to permit_actions(:index, :show, :create) }
  end

  context "when the user is not an admin" do
    subject { described_class.new(no_admin, SpreadsheetImport) }

    it { is_expected.to forbid_actions(:index, :show, :create) }
  end

  describe "Scope" do
    let!(:admin_import) { create(:spreadsheet_import) }
    let!(:other_import) { create(:spreadsheet_import) }

    it "resolves every import for an admin" do
      resolved = SpreadsheetImportPolicy::Scope.new(admin, SpreadsheetImport.all).resolve

      expect(resolved).to contain_exactly(admin_import, other_import)
    end

    it "resolves nothing for a no_admin user" do
      resolved = SpreadsheetImportPolicy::Scope.new(no_admin, SpreadsheetImport.all).resolve

      expect(resolved).to be_empty
    end
  end
end
