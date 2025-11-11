require 'rails_helper'

RSpec.describe 'Profile UI', type: :system do
  let!(:user) { create(:user, full_name: 'Marcos Gomes', email: 'marcos@example.com', password: 'password123') }

  before do
    driven_by(:rack_test)
    login_as(user, scope: :user)
  end

  describe 'Viewing profile' do
    it 'shows the user information correctly formatted' do
      visit profile_path
      expect(page).to have_content('Meu Perfil')
      expect(page).to have_content('Marcos Gomes')
      expect(page).to have_content('marcos@example.com')
      expect(page).to have_link('Editar')
      expect(page).to have_button('Excluir Conta')
    end
  end

  describe 'Editing profile' do
    it 'shows a styled form for editing' do
      visit edit_profile_path
      expect(page).to have_selector('form')
      expect(page).to have_field('Nome completo')
      expect(page).to have_field('Email')
      expect(page).to have_button('Salvar alterações')
    end
  end

  describe 'Avatar upload' do
    it 'shows a preview area for avatar' do
      visit edit_profile_path
      expect(page).to have_content('Foto de Perfil')
      expect(page).to have_selector('input[type=file]')
    end
  end
end
