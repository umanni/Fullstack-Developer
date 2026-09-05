require "rails_helper"

RSpec.describe "Admin spreadsheet import live progress", type: :system do
  it "updates the progress bar and status live as the background job processes rows" do
    admin = create(:user, :admin, password: "password123")

    sign_in_via_ui(admin)
    click_link "Importações de Planilha"
    click_link "Nova Importação"

    attach_file "Planilha (CSV ou XLSX)", Rails.root.join("spec/fixtures/files/valid_import.csv")
    expect(page).to have_checked_field("Este arquivo tem uma linha de cabeçalho")
    click_button "Enviar"

    expect(page).to have_content("Planilha enviada. A importação está sendo processada em segundo plano.")
    within("#spreadsheet_import_progress") do
      expect(page).to have_content("Pendente")
      expect(page).to have_content("0 / 0 linhas processadas")
    end

    SpreadsheetImportJob.perform_now(SpreadsheetImport.last.id)

    within("#spreadsheet_import_progress") do
      expect(page).to have_content("Concluída")
      expect(page).to have_content("3 / 3 linhas processadas")
    end

    expect(User.exists?(email: "alice@example.com")).to be true
  end
end
