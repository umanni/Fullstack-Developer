# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'admin/users' do
  let(:admin_user) { create(:user) }

  before do
    sign_in admin_user
    visit '/admin/users'
  end

  feature 'Scopes' do
    let!(:non_admins) { create_list(:user, 2, :non_admin) }
    let!(:admins) { create_list(:user, 2, :admin) }

    scenario 'has "all" scope' do
      find_link('All', href: '/admin/users?scope=all').click

      within '#index_table_users' do
        expect(page).to have_content(non_admins.first.id) &
                        have_content(non_admins.second.id) &
                        have_content(admins.first.id) &
                        have_content(admins.second.id)
      end
    end

    scenario 'has "non admins" scope' do
      find_link('Non Admins', href: '/admin/users?scope=non_admins').click

      within '#index_table_users' do
        expect(page).to have_content(non_admins.first.id) &
                        have_content(non_admins.second.id)
      end
    end

    scenario 'has "admins" scope' do
      find_link('Admins', href: '/admin/users?scope=admins').click

      within '#index_table_users' do
        expect(page).to have_content(admins.first.id) &
                        have_content(admins.second.id)
      end
    end
  end

  feature 'Main Content' do
    scenario 'has table with user headers' do
      within '#index_table_users thead' do
        expect(page).to have_text('ID') &
                        have_text('Full Name') &
                        have_text('Email') &
                        have_text('Role')
      end
    end

    scenario 'has table with users' do
      within '#index_table_users tbody' do
        expect(page).to have_text(admin_user.id) &
                        have_text(admin_user.full_name) &
                        have_text(admin_user.role.titleize)
      end
    end
  end

  feature 'Filters' do
    scenario 'by Full Name' do
      within '#filters_sidebar_section' do
        expect(page).to have_css('label', text: 'Full Name')
      end
    end

    scenario 'by Email' do
      within '#filters_sidebar_section' do
        expect(page).to have_css('label', text: 'Email')
      end
    end

    scenario 'by Role' do
      within '#filters_sidebar_section' do
        expect(page).to have_css('label', text: 'Role')
      end
    end

    scenario 'by Current sign in at' do
      within '#filters_sidebar_section' do
        expect(page).to have_css('label', text: 'Current sign in at')
      end
    end

    scenario 'by Created at' do
      within '#filters_sidebar_section' do
        expect(page).to have_css('label', text: 'Created at')
      end
    end
  end

  feature 'Actions' do
    feature 'New' do
      before do
        within '.action_items' do
          click_link 'New User'
        end
      end

      scenario 'must have the form working' do
        fill_in 'Full Name', with: 'Carlos Alberto'
        fill_in 'Email', with: 'carlos_alberto@email.com'
        find('#user_role').find(:option, 'Non admin').select_option
        fill_in 'Password*', with: 'password', exact: true
        fill_in 'Password confirmation', with: 'password'

        click_button 'Create User'
        expect(page).to have_css('.flash_notice', text: 'User was successfully created.') &
                        have_text('Carlos Alberto') &
                        have_text('carlos_alberto@email.com') &
                        have_text('Non Admin')
      end
    end

    feature 'Show' do
      scenario 'have admin for login information' do
        click_link('View', href: "/admin/users/#{admin_user.id}")

        expect(page).to have_text(admin_user.full_name) &
                        have_text(admin_user.email) &
                        have_text(admin_user.role.titleize)
      end
    end

    feature 'Edit' do
      scenario 'updates user information' do
        within "#user_#{admin_user.id}" do
          click_link('Edit')
        end
        fill_in 'Full Name', with: 'Bruno Roberto'
        click_button 'Update User'

        expect(page).to have_css('.flash_notice', text: 'User was successfully updated.') &
                        have_text('Bruno Roberto')
      end
    end

    feature 'Destroy' do
      let!(:user) { create(:user) }

      scenario 'confirm delete admin user' do
        visit '/admin/users'
        within "#user_#{user.id}" do
          click_link('Delete')
        end

        expect(page).to have_text('User was successfully destroyed.') &
                        have_no_link('Delete', href: "/admin/users/#{user.id}")
      end

      scenario 'cancel delete admin user', js: true do
        visit '/admin/users'
        within "#user_#{user.id}" do
          page.dismiss_confirm do
            click_link('Delete')
          end
        end

        expect(page).to have_link('Delete', href: "/admin/users/#{user.id}")
      end
    end
  end
end
