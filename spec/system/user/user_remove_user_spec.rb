require 'rails_helper'

describe 'Remove user', type: :system do
  it 'removes user from the database' do
    user1 = create(:user)
    user2 = create(:user)
    login_as(user1)

    visit(profile_path)
    click_on('Edit')

    expect(User.count).to eq 2

    click_on('Cancel my account')
    expect(User.count).to eq(1)
    expect(User.first).to eq(user2)
    expect(page).to have_content(
      'Bye! Your account has been successfully cancelled. We hope to see you again soon.'
    )
    expect(page).to have_content('Welcome, folks!')
    expect(page).to have_link('Sign In')
  end
end
