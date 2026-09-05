require "rails_helper"

RSpec.describe SpreadsheetImportRowImporter do
  include ActionCable::TestHelper

  let(:spreadsheet_import) { create(:spreadsheet_import) }
  let(:importer) { described_class.new(spreadsheet_import) }

  before { importer } # force creation (and its associated admin user) outside the expect blocks below

  describe "#import" do
    it "creates a user and returns true for a valid row" do
      expect {
        expect(importer.import(2, { "nome" => "Alice Example", "email" => "alice@example.com" })).to be true
      }.to change(User, :count).by(1)

      user = User.find_by(email: "alice@example.com")
      expect(user.full_name).to eq("Alice Example")
      expect(user).to be_no_admin
    end

    it "gives the imported user an unguessable random password" do
      importer.import(2, { "nome" => "Alice Example", "email" => "alice@example.com" })

      user = User.find_by(email: "alice@example.com")
      expect(user.authenticate("password123")).to be false
    end

    it "sends a welcome e-mail so the user can set a real password" do
      expect {
        importer.import(2, { "nome" => "Alice Example", "email" => "alice@example.com" })
      }.to have_enqueued_mail(PasswordsMailer, :welcome)
    end

    it "does not create a user or send an e-mail, and records a row error, for invalid data" do
      expect {
        expect {
          expect(importer.import(3, { "nome" => "Missing Email", "email" => "" })).to be false
        }.not_to change(User, :count)
      }.not_to have_enqueued_mail(PasswordsMailer, :welcome)

      error = spreadsheet_import.spreadsheet_import_row_errors.sole
      expect(error.row_number).to eq(3)
      expect(error.message).to match(/e-mail não pode ficar em branco/i)
    end

    it "does not trigger a dashboard broadcast for the imported user (bulk import path)" do
      expect {
        importer.import(2, { "nome" => "Alice Example", "email" => "alice@example.com" })
      }.not_to have_broadcasted_to("admin_dashboard")
    end
  end
end
