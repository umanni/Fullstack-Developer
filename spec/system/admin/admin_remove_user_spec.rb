require "rails_helper"

describe 'Admin remove user', type: :system do
  it 'is accessed through the dashboard' do
    user = create(:user, full_name: 'Alberto S')
    admin = create(:user, role: :admin, full_name: 'Beatriz C')
    login_as(admin)

    visit(admin_dashboard_path)
    options_div = find('.dropdown', match: :first)
    within options_div do
      click_on('Options')
    end

    expect(page).to have_button('Remove user')
  end

  it 'removes user from the database' do
    user = create(:user, full_name: 'Alberto S')
    admin = create(:user, role: :admin, full_name: 'Beatriz C')
    login_as(admin)

    visit(admin_dashboard_path)
    options_div = find('.dropdown', match: :first)
    within options_div do
      click_on('Options')
    end

    expect(User.count).to eq 2

    within options_div do
      click_on('Remove user')
    end
    expect(User.count).to eq(1)
    expect(User.first).to eq(admin)
    expect(page).to have_content('The user has been removed successfully.')
    expect(page).to have_content('Users')
  end

  context 'and they are another admin' do
    it 'removes the admin from the database' do
      admin1 = create(:user, role: :admin, full_name: 'Beatriz C')
      admin2 = create(:user, role: :admin, full_name: 'Alberto V')
      login_as(admin1)

      visit(admin_dashboard_path)
      options_div = find('.dropdown', match: :first)
      within options_div do
        click_on('Options')
      end

      expect(User.count).to eq 2

      within options_div do
        click_on('Remove user')
      end
      expect(User.count).to eq(1)
      expect(User.first).to eq(admin1)
      expect(page).to have_content('The user has been removed successfully.')
      expect(page).to have_content('Users')
    end
  end

  context 'and they are the same admin' do
    context 'and there is another admin' do
      it 'removes the same admin from the database' do
        admin1 = create(:user, role: :admin, full_name: 'Beatriz C')
        admin2 = create(:user, role: :admin, full_name: 'Alberto V')
        login_as(admin1)

        visit(admin_dashboard_path)
        options_div = find('.dropdown', match: :first)
        within options_div do
          click_on('Options')
        end

        expect(User.count).to eq 2

        within options_div do
          click_on('Remove user')
        end
        expect(User.count).to eq(1)
        expect(User.first).to eq(admin1)
        expect(page).to have_content('The user has been removed successfully.')
        expect(page).to have_content('Users')
      end
    end

    context 'and there is not another admin' do
      it 'shows error message' do
        admin = create(:user, role: :admin)
        login_as(admin)

        visit(admin_dashboard_path)
        click_on('Options')
        click_on('Remove user')

        expect(User.count).to eq(1)
        expect(User.first).to eq(admin)
        expect(page).to have_content('In order to remove this user, please create another administrator.')
        expect(page).to have_button('Upload Users')
      end
    end
  end
end
