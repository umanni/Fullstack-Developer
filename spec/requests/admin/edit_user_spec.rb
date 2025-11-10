require "rails_helper"

describe 'GET admin/id/edit', type: :request do
  context 'before login' do
    it 'redirects to login' do
      user = create(:user)

      get(edit_admin_path(user.id))

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_url)
    end
  end

  context 'as a regular user' do
    it 'redirects to root' do
      user1 = create(:user)
      user2 = create(:user, full_name: 'Abel A', email: 'a@email.com')
      login_as(user1)

      get(edit_admin_path(user2.id))

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_url)
    end
  end

  context 'as an admin' do
    it 'returns status success' do
      admin = create(:user, role: :admin)
      user = create(:user, full_name: 'Abel A', email: 'a@email.com')
      login_as(admin)

      get(edit_admin_path(user.id))

      expect(response).to have_http_status(:success)
    end
  end
end
