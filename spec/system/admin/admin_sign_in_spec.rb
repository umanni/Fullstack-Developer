require "rails_helper"

describe 'Admin sign-in', type: :system do
  context 'success' do
    it 'shows users list and sign out option' do
      admin = create(:user, role: :admin)
      user1 =  create(:user)
      user2 =  create(:user)

      visit(root_path)
      click_on('Sign In')

      within 'form' do
        fill_in 'Email', with: admin.email
        fill_in 'Password', with: admin.password
        click_on('Sign in')
      end

      expect(page).not_to have_link('Sign In')
      expect(page).not_to have_link('Sign Up')
      expect(page).to have_link('Profile')
      expect(page).to have_link('Dashboard')
      expect(page).to have_button('Sign Out')
      expect(page).to have_content('Signed in successfully.')

      expect(page).to have_content(admin.full_name)
      expect(page).to have_content(user1.full_name)
      expect(page).to have_content(user2.full_name)
    end

    it 'allows the admin to sign out' do
      admin = create(:user, role: :admin)
      login_as(admin)

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
      admin = create(:user, full_name: 'João da Silva', role: :admin)

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
