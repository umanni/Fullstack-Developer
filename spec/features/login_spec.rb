# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Login Redirect' do
  context 'when user is admin' do
    let(:admin_user) { create(:user, :admin) }

    scenario 'login to /admin/dashboard' do
      visit '/login'
      fill_in 'Email', with: admin_user.email
      fill_in 'Password', with: 'password', exact: true
      click_button 'Log in'

      expect(page).to have_current_path(admin_dashboard_path)
    end
  end

  context 'when user is non admin' do
    let(:non_admin) { create(:user, :non_admin) }

    scenario 'login to Punchclock root page' do
      visit '/login'
      fill_in 'Email', with: non_admin.email
      fill_in 'Password', with: 'password', exact: true
      click_button 'Log in'


      expect(page).to have_current_path(root_path)
    end
  end
end
