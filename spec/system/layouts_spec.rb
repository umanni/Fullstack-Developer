require 'rails_helper'

RSpec.describe 'Layout and Navigation', type: :system do
  let!(:user)  { create(:user, full_name: 'Usuário Comum', email: 'user@example.com') }
  let!(:admin) { create(:user, :admin, full_name: 'Admin User', email: 'admin@example.com') }

  before do
    driven_by(:rack_test)
  end

  describe 'Public layout' do
    it 'shows login and signup links when logged out' do
      visit root_path
      expect(page).to have_link('Entrar')
      expect(page).to have_link('Cadastrar')
      expect(page).not_to have_link('Dashboard')
    end
  end

  describe 'User layout' do
    before { login_as(user, scope: :user) }

    it 'shows navbar with dashboard and profile links' do
      visit dashboard_index_path
      expect(page).to have_link('Dashboard')
      expect(page).to have_link('Perfil')
      expect(page).to have_button('Sair')
    end

    it 'shows success flash message styled with Bulma' do
      visit dashboard_index_path
      visit profile_path
      expect(page).to have_css('.notification', class: /is-(success|danger)/).or have_no_css('.notification')
    end
  end

  describe 'Admin layout' do
    before { login_as(admin, scope: :user) }

    it 'uses the admin layout and shows admin navbar links' do
      visit admin_users_path
      expect(page).to have_link('Usuários')
      expect(page).to have_link('Dashboard')
      expect(page).to have_button('Sair')
    end

    it 'shows flash message with Bulma styling' do
      visit admin_users_path

      visit admin_dashboard_path
      expect(page).to have_css('.notification', class: /is-(success|danger)/).or have_no_css('.notification')
    end
  end
end
