require "rails_helper"

describe 'DELETE admin/id', type: :request do
  context 'before login' do
    it 'redirects to login' do
      user1 = create(:user)
      user2 = create(:user)

      delete(admin_path(user2.id))

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_url)
    end
  end

  context 'as a regular user' do
    it 'redirects to root' do
      user1 = create(:user)
      user2 = create(:user)
      login_as(user1)

      delete(admin_path(user2.id))

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_url)
    end
  end

  context 'as an admin' do
    it 'returns error message' do
      admin = create(:user, role: :admin)
      user = create(:user)
      login_as(admin)

      expect(User.count).to eq(2)

      delete(admin_path(user.id))

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(admin_dashboard_url)
      expect(User.count).to eq(1)
      expect(User.first).to eq(admin)
    end
  end
end
