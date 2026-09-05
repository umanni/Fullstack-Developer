require "rails_helper"

RSpec.describe "Admin dashboard live updates", type: :system do
  it "reflects a user created by one admin in another admin's dashboard without a reload" do
    admin_one = create(:user, :admin, password: "password123")
    admin_two = create(:user, :admin, password: "password123")

    using_session(:admin_two) do
      sign_in_via_ui(admin_two)

      within("#dashboard_counts") do
        expect(page).to have_content("Total de Usuários")
        expect(page).to have_content("2")
      end
    end

    using_session(:admin_one) do
      sign_in_via_ui(admin_one)
      click_link "Usuários"
      click_link "Novo Usuário"

      fill_in "Nome", with: "Grace Hopper"
      fill_in "E-mail", with: "grace-live@example.com"
      fill_in "Senha", with: "password123", exact: true
      fill_in "Confirmar senha", with: "password123"
      click_button "Criar Usuário"

      expect(page).to have_content("Usuário criado com sucesso")
    end

    using_session(:admin_two) do
      within("#dashboard_counts") do
        expect(page).to have_content("3")
      end
    end
  end
end
