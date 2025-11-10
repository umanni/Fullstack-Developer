require "rails_helper"

describe 'User sign-in', type: :system do
  context 'success' do
    it 'shows user first name and sign out option' do
      user = create(:user)

      visit(root_path)
      click_on('Sign In')

      within 'form' do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_on('Sign in')
      end

      expect(page).not_to have_link('Sign In')
      expect(page).not_to have_link('Sign Up')
      expect(page).to have_link('Profile')
      expect(page).not_to have_link('Dashboard')
      expect(page).to have_button('Sign Out')
      expect(page).to have_content("Signed in successfully.")
      expect(page).to have_content(user.full_name)
      expect(page).to have_content(user.email)
    end

    it 'allows the user to sign out' do
      user = create(:user)
      login_as(user)

      visit(root_path)
      click_on('Sign Out')

      expect(page).to have_link('Sign In')
      expect(page).not_to have_link('Profile')
      expect(page).not_to have_button('Sign Out')
      expect(page).to have_content("Signed out successfully.")
      expect(page).to have_content('Welcome, folks!')
    end
  end

  context 'fails' do
    it 'shows error message' do
      user = create(:user, full_name: 'João da Silva')

      visit(root_path)
      click_on('Sign In')

      within 'form' do
        click_on('Sign in')
      end

      expect(page).to have_link('Sign In')
      expect(page).not_to have_link('Profile')
      expect(page).not_to have_button('Sign Out')
      expect(page).to have_content("Invalid Email or password.")
    end
  end
end
