require "rails_helper"

describe 'Admin import users', type: :system do
  let(:file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'sample_users_file.csv'), 'text/csv') }

  it 'is acessed through the admin dashboard' do
    admin = create(:user, role: :admin)
    login_as(admin)

    visit(admin_dashboard_path)

    expect(page).to have_button('Upload Users')
  end

  it 'returns error message if no file is attached' do
    admin = create(:user, role: :admin)
    login_as(admin)

    visit(admin_dashboard_path)
    click_on('Upload Users')

    expect(page).to have_content('Please select a CSV file to upload.')
  end

  it 'returns error message if the attachement is not a csv' do
    admin = create(:user, role: :admin)
    login_as(admin)

    visit(admin_dashboard_path)
    attach_file('file', Rails.root.join('spec', 'fixtures', 'files', 'avatar_image.jpg'))
    click_on('Upload Users')

    expect(page).to have_content('Please select a CSV file instead.')
  end

  it 'returns sucess message after import' do
    admin = create(:user, role: :admin)
    login_as(admin)

    visit(admin_dashboard_path)
    attach_file('file', Rails.root.join('spec', 'fixtures', 'files', 'sample_users_file.csv'))
    click_on('Upload Users')

    expect(page).to have_content('5 users were successfully imported.')
  end
end
