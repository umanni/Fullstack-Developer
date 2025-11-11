require 'rails_helper'

RSpec.describe 'Profile management', type: :system do
  let(:user) { create(:user) }

  it 'allows user to view, edit and delete their profile' do
    sign_in user
    visit profile_path

    expect(page).to have_content(user.full_name)
    expect(page).to have_content(user.email)

    click_link 'Editar'
    fill_in 'Full name', with: 'Usuário Atualizado'
    click_button 'Salvar'

    expect(page).to have_content('Perfil atualizado com sucesso')
    expect(page).to have_content('Usuário Atualizado')

    click_link 'Excluir conta'
    expect(page).to have_content('Conta excluída com sucesso')
  end
end
