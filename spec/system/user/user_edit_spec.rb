require 'rails_helper'

describe 'Edit user', type: :system do
  it 'shows the filled form' do
    user = create(:user)
    login_as(user)

    visit(profile_path)
    click_on('Edit')

    expect(page).to have_content('Edit User')
    expect(page).to have_field('Full name', with: user.full_name)
    expect(page).to have_field('Email', with: user.email)
    expect(page).to have_content("Avatar image (leave blank if you don't want to change it)")
    expect(page).to have_content("Password (leave blank if you don't want to change it)")
    expect(page).to have_content('6 characters minimum')
    expect(page).to have_content('Password confirmation')
    expect(page).to have_content('Current password (we need your current password to confirm your changes)')
    expect(page).to have_link('Cancel')
  end

  context 'fails' do
    it 'shows error message' do
      user = create(:user)
      login_as(user)

      visit(profile_path)
      click_on('Edit')

      fill_in 'Current password', with: 'password'
      click_on('Update')

      expect(page).to have_content('1 error prohibited this user from being saved:')
      expect(page).to have_content("Current password is invalid")
    end
  end

  context 'success' do
    it 'updates the user adding new avatar image' do
      user = create(:user)
      login_as(user)

      visit(profile_path)
      click_on('Edit')

      fill_in 'Full name', with: 'Marta Souza'
      fill_in 'Email', with: 'marta@email.com'
      fill_in 'Password', with: '12345678'
      fill_in 'Password confirmation', with: '12345678'
      fill_in 'Current password', with: user.password
      page.attach_file('Avatar image', Rails.root.join('spec', 'fixtures', 'files', 'avatar_image.jpg'))
      click_on('Update')

      expect(page).to have_content('Your account has been updated successfully.')
      expect(page).to have_content('Marta Souza')
      expect(page).to have_content('marta@email.com')
    end

    it 'updates the user leaving avatar image blank' do
      user = create(:user)
      login_as(user)

      visit(profile_path)
      click_on('Edit')


      fill_in 'Full name', with: 'Marta Souza'
      fill_in 'Email', with: 'marta@email.com'
      fill_in 'Password', with: '12345678'
      fill_in 'Password confirmation', with: '12345678'
      fill_in 'Current password', with: user.password
      click_on('Update')

      expect(page).to have_content('Your account has been updated successfully.')
      expect(page).to have_content('Marta Souza')
      expect(page).to have_content('marta@email.com')
    end
  end

  it 'returns to the profile page if canceled' do
    user = create(:user)
    login_as(user)

    visit(profile_path)
    click_on('Edit')
    click_on('Cancel')

    expect(page).to have_current_path('/profile')
  end
end
