require "rails_helper"

describe 'POST /admin', type: :request do
  context 'before login' do
    it 'redirects to login' do
      user1 = create(:user)

      post(admin_index_path, params: { user: { full_name: 'Abel B', email: 'b@email.com' } })

      expect(response).to redirect_to(new_user_session_url)
    end
  end

  context 'as a regular user' do
    it 'redirects to login' do
      user = create(:user)
      login_as(user)

      post(admin_index_path, params: { user: { full_name: 'Abel B', email: 'b@email.com' } })

      expect(response).to redirect_to(root_url)
    end
  end

  context 'as an admin' do
    it 'creates the user' do
      admin = create(:user, role: :admin)
      login_as(admin)

      avatar_image = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'avatar_image.jpg'), 'image/jpg')
      post(admin_index_path, params: { user: { full_name: 'Abel B', email: 'b@email.com', avatar_image: avatar_image } })

      expect(response).to redirect_to(admin_dashboard_url)
      expect(User.count).to eq(2)
      new_user = User.last
      expect(new_user.full_name).to eq('Abel B')
      expect(new_user.email).to eq('b@email.com')
    end
  end
end
