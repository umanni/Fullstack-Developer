require "rails_helper"

describe 'POST /admin/import_users', type: :request do
  let(:file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'sample_users_file.csv'), 'text/csv') }

  context 'before login' do
    it 'redirects to login' do
      user1 = create(:user)

      post(import_admin_index_path, params: { file: file })

      expect(response).to redirect_to(new_user_session_url)
    end
  end

  context 'as a regular user' do
    it 'redirects to login' do
      user = create(:user)
      login_as(user)

      post(import_admin_index_path, params: { file: file })

      expect(response).to redirect_to(root_url)
    end
  end

  context 'as an admin' do
    it 'redirects to admin dashboard if the file is empty' do
      admin = create(:user, role: :admin)
      login_as(admin)

      post(import_admin_index_path, params: { file: nil })

      expect(User.count).to eq(1)
      expect(response).to redirect_to(admin_dashboard_url)
    end

    it 'redirects to admin dashboard if the file is empty' do
      admin = create(:user, role: :admin)
      login_as(admin)

      post(import_admin_index_path, params: { file: nil })

      expect(User.count).to eq(1)
      expect(response).to redirect_to(admin_dashboard_url)
    end

    it 'creates users from the file respecting the validations' do
      admin = create(:user, role: :admin, full_name: 'Abel Duarte')
      login_as(admin)

      expect(User.count).to eq(1)
      post(import_admin_index_path, params: { file: file })

      expect(User.count).to eq(6)
      expect(User.order(:full_name).pluck(:full_name)).to eq(
        [ 'Abel Duarte', 'Alice Souza', 'Carla Andrade', 'Helena Silva', 'Marcos Souza', 'Monique Leite' ]
      )

      expect(User.last.avatar_image.attached?).to eq(true)
      expect(response).to redirect_to(admin_dashboard_url)
    end
  end
end
