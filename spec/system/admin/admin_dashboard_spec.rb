require "rails_helper"

describe 'Admin dashboard', type: :system do
  it 'cannot be accessed without login' do
    admin = create(:user, role: :admin)
    user = create(:user)

    visit(admin_dashboard_path)

    expect(page).to have_link('Sign In')
    expect(page).not_to have_link('Dashboard')
    expect(page).to have_button('Sign in')
    expect(page).to have_content('You need to sign in or sign up before continuing.')
  end

  it 'cannot be accessed by a regular user' do
    admin = create(:user, role: :admin)
    user = create(:user)
    login_as(user)

    visit(admin_dashboard_path)

    expect(page).to have_link('Profile')
    expect(page).not_to have_link('Dashboard')
    expect(page).to have_content('Restricted area')
    expect(page).to have_content('Welcome, folks!')
  end

  context 'success' do
    it 'can be accessed by an admin' do
      admin = create(:user, role: :admin)
      user1 = create(:user)
      user2 = create(:user)
      login_as(admin)

      visit(root_path)
      click_on('Dashboard')

      expect(page).to have_link('Profile')
      expect(page).to have_content('3')
      expect(page).to have_content('users')
      expect(page).to have_content('1')
      expect(page).to have_content('administrator')
      expect(page).to have_content('2')
      expect(page).to have_content('regular users')
      expect(page).to have_content('User')
      expect(page).to have_content('Role')
      expect(page).to have_content(admin.full_name)
      expect(page).to have_content(admin.email)
      expect(page).to have_content(user1.full_name)
      expect(page).to have_content(user1.email)
      expect(page).to have_content(user2.full_name)
      expect(page).to have_content(user2.email)
      expect(page).to have_css('.pagy-bootstrap.series-nav')
    end
  end
end
