require 'rails_helper'

RSpec.feature 'Login', type: :feature do
  let(:user) { create(:user) }

  # This scenario tests if a user logs in successfully
  scenario 'user logs in successfully' do
    visit new_user_session_path

    # Fill in email and password fields with valid user credentials and click on submit button
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Submit'

    # Expect to be redirected to the user profile or dashboard page and see success message
    expect(page).to have_current_path(user_profile_path) if :user && :user.user?
    expect(page).to have_current_path(dashboard_path) if :user && :user.admin?
    expect(page).to have_content('Signed in successfully.')

  end

  # This scenario tests if a user enters incorrect credentials
  scenario 'user enters incorrect credentials' do
    visit new_user_session_path

    # Fill in email and password fields with invalid password and click on submit button
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'incorrectpassword'
    click_on 'Submit'

    # Expect to stay on the same page and see error message
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content('Invalid Email or password.')
  end
end
