require "rails_helper"

describe 'Admin edit user', type: :system do
  it 'is acessed through the admin dashboard' do
    admin = create(:user, role: :admin)
    login_as(admin)

    visit(admin_dashboard_path)
    click_on('Options')
    click_on('Edit')

    expect(page).to have_content('Edit User')
    expect(page).to have_field('Full name', with: admin.full_name)
    expect(page).to have_field('Email', with: admin.email)
    expect(page).to have_field('Avatar image')
    expect(page).to have_button('Update')
  end

  it 'updates the user information' do
    admin = create(:user, role: :admin)
    user = create(:user, full_name: 'Abel A', email: 'a@email.com', role: :admin)
    login_as(admin)

    visit(edit_admin_path(user.id))
    fill_in 'Full name', with: 'Abel B'
    fill_in 'Email', with: 'b@email.com'
    select 'administrator', from: 'Role'
    click_on('Update')

    expect(page).to have_content('2')
    expect(page).to have_content('administrators')
    expect(page).to have_content('Abel B')
    expect(page).to have_content('b@email.com')
    expect(page).not_to have_content('Abel A')
    expect(page).not_to have_content('a@email.com')
    expect(page).to have_content('The user has been updated successfully.')
  end

  it 'shows validation errors' do
    admin = create(:user, role: :admin, email: 'b@email.com')
    user = create(:user, full_name: 'Abel A', email: 'a@email.com')
    login_as(admin)

    visit(edit_admin_path(user.id))
    fill_in 'Full name', with: 'Abel B'
    fill_in 'Email', with: 'b@email.com'
    click_on('Update')

    expect(page).to have_content('1 error prohibited this user from being saved:')
    expect(page).to have_content("Email has already been taken")
  end

  it 'returns to the dashboard if canceled' do
    admin = create(:user, role: :admin)
    user = create(:user)
    login_as(admin)

    visit(edit_admin_path(user.id))
    click_on('Cancel')

    expect(page).to have_current_path('/admin/dashboard')
  end

  context 'from admin to no_admin' do
    context 'and there is another admin' do
      it 'updates the user role to no_admin' do
        admin1 = create(:user, role: :admin)
        admin2 = create(:user, full_name: 'Abel A', email: 'a@email.com', role: :admin)
        login_as(admin1)

        visit(edit_admin_path(admin2.id))
        select 'regular user', from: 'Role'
        click_on('Update')

        expect(page).to have_content('The user has been updated successfully.')
      end
    end

    context 'and there is not another admin' do
      it 'updates the user role to no_admin' do
        admin = create(:user, role: :admin)
        login_as(admin)

        visit(edit_admin_path(admin.id))
        select 'regular user', from: 'Role'
        click_on('Update')

        expect(page).to have_content('Edit User')
        expect(page).to have_content("In order to change this user's role, please create another administrator.")
      end
    end
  end
end
