require "rails_helper"

describe 'User profile', type: :system do
  context 'after login' do
    it 'shows user information' do
      user = create(:user, full_name: 'João da Silva', email: 'jsilva@email.com')
      login_as(user)

      visit(root_path)

      within 'nav' do
        click_on('Profile')
      end

      expect(page).to have_content('João da Silva')
      expect(page).to have_content('jsilva@email.com')
      expect(page).to have_link('Edit')
    end
  end

  context 'before login' do
    it 'redirects to sign in' do
      user = create(:user, full_name: 'João da Silva', email: 'jsilva@email.com')

      visit(profile_path)

      expect(page).to have_content('You need to sign in or sign up before continuing.')
      expect(page).to have_button('Sign in')
      expect(page).not_to have_content('João da Silva')
      expect(page).not_to have_content('jsilva@email.com')
    end
  end
end
