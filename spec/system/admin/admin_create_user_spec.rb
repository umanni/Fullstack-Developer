require "rails_helper"

describe 'Admin create user', type: :system do
  it 'is acessed through the admin dashboard' do
    admin = create(:user, role: :admin)
    login_as(admin)

    visit(admin_dashboard_path)
    click_on('Create new user')

    expect(page).to have_content('New User')
    expect(page).to have_field('Full name')
    expect(page).to have_field('Email')
    expect(page).to have_field('Avatar image')
    expect(page).to have_button('Create user')
  end

  it 'creates a new user' do
    admin = create(:user, role: :admin)
    login_as(admin)

    visit(new_admin_path)
    fill_in 'Full name', with: 'Abel B'
    fill_in 'Email', with: 'b@email.com'
    page.attach_file('Avatar image', Rails.root.join('spec', 'fixtures', 'files', 'avatar_image.jpg'))
    click_on('Create user')

    expect(page).to have_content('Abel B')
    expect(page).to have_content('b@email.com')
  end

  it 'shows validation errors' do
    admin = create(:user, role: :admin, email: 'b@email.com')
    login_as(admin)

    visit(new_admin_path)
    fill_in 'Full name', with: 'Abel B'
    fill_in 'Email', with: 'b@email.com'
    page.attach_file('Avatar image', Rails.root.join('spec', 'fixtures', 'files', 'avatar_image.jpg'))
    click_on('Create user')

    expect(page).to have_content('1 error prohibited this user from being saved:')
    expect(page).to have_content("Email has already been taken")
  end

  it 'returns to the dashboard if canceled' do
    admin = create(:user, role: :admin)
    login_as(admin)

    visit(new_admin_path)
    click_on('Cancel')

    expect(page).to have_current_path('/admin/dashboard')
  end
end
