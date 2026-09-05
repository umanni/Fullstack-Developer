require "rails_helper"

RSpec.describe SpreadsheetImportJob, type: :job do
  def spreadsheet_import_with(fixture_name, content_type)
    spreadsheet_import = create(:spreadsheet_import)
    spreadsheet_import.file.attach(
      io: File.open(Rails.root.join("spec/fixtures/files", fixture_name)),
      filename: fixture_name,
      content_type: content_type
    )
    spreadsheet_import
  end

  shared_examples "a mixed spreadsheet import" do |fixture_name, content_type|
    it "creates a user per valid row and a SpreadsheetImportRowError per invalid row, without aborting" do
      create(:user, email: "existing@example.com")
      spreadsheet_import = spreadsheet_import_with(fixture_name, content_type)

      expect {
        described_class.perform_now(spreadsheet_import.id)
      }.to change(User, :count).by(2) # dave@example.com and erin@example.com (or heidi/ivan for xlsx)

      spreadsheet_import.reload
      expect(spreadsheet_import).to be_completed
      expect(spreadsheet_import.total_rows).to eq(5)
      expect(spreadsheet_import.processed_rows).to eq(5)

      errors = spreadsheet_import.spreadsheet_import_row_errors.order(:row_number)
      expect(errors.pluck(:row_number)).to eq([ 3, 4, 5 ])
      expect(errors[0].message).to match(/e-mail não pode ficar em branco/i)
      expect(errors[1].message).to match(/e-mail não é válido/i)
      expect(errors[2].message).to match(/e-mail já está em uso/i)
    end

    it "gives imported users an unguessable random password" do
      create(:user, email: "existing@example.com")
      spreadsheet_import = spreadsheet_import_with(fixture_name, content_type)

      described_class.perform_now(spreadsheet_import.id)

      imported_user = User.where.not(email: [ "existing@example.com", spreadsheet_import.user.email ]).first
      expect(imported_user.authenticate("password123")).to be false
    end
  end

  include_examples "a mixed spreadsheet import", "mixed_import.csv", "text/csv"
  include_examples "a mixed spreadsheet import", "mixed_import.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

  it "marks the import as failed and logs a warning when the spreadsheet cannot be parsed" do
    spreadsheet_import = spreadsheet_import_with("malformed_import.csv", "text/csv")

    expect(Rails.logger).to receive(:warn).with(/failed to process import/)

    expect {
      described_class.perform_now(spreadsheet_import.id)
    }.not_to change(User, :count)

    expect(spreadsheet_import.reload).to be_failed
    expect(spreadsheet_import.spreadsheet_import_row_errors).to be_empty
  end

  it "does nothing when the import no longer exists" do
    expect {
      described_class.perform_now(0)
    }.not_to raise_error
  end

  it "does nothing when the import is not pending" do
    spreadsheet_import = create(:spreadsheet_import, status: :completed)

    expect {
      described_class.perform_now(spreadsheet_import.id)
    }.not_to change(User, :count)
  end

  describe "progress broadcast throttling" do
    include ActionCable::TestHelper

    it "throttles progress broadcasts instead of firing on every row" do
      spreadsheet_import = create(:spreadsheet_import)
      rows = 25.times.map { |i| "Person #{i},person#{i}@example.com" }
      spreadsheet_import.file.attach(
        io: StringIO.new("nome,email\n#{rows.join("\n")}\n"),
        filename: "many_rows.csv",
        content_type: "text/csv"
      )

      # status:processing (1) + total_rows set (1) + throttled progress every 10 rows
      # (rows 10 and 20, for 25 rows) + status:completed (1, which already reflects
      # the final count) = 5. A per-row broadcast would have produced 25+ instead.
      expect {
        described_class.perform_now(spreadsheet_import.id)
      }.to have_broadcasted_to("spreadsheet_import_#{spreadsheet_import.id}").exactly(5).times
    end
  end

  describe "dashboard broadcast" do
    include ActionCable::TestHelper

    it "broadcasts dashboard counts once after the import, not once per created user" do
      spreadsheet_import = spreadsheet_import_with("valid_import.csv", "text/csv")

      expect {
        described_class.perform_now(spreadsheet_import.id)
      }.to have_broadcasted_to("admin_dashboard").exactly(1).times
    end

    it "does not broadcast dashboard counts when no user was created" do
      spreadsheet_import = spreadsheet_import_with("malformed_import.csv", "text/csv")

      expect {
        described_class.perform_now(spreadsheet_import.id)
      }.not_to have_broadcasted_to("admin_dashboard")
    end
  end
end
