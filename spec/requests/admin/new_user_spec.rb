require "rails_helper"

describe 'GET /admin/new', type: :request do
  context 'before login' do
    it 'redirects to login' do
      user = create(:user)

      get(new_admin_path)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_url)
    end
  end

  context 'as a regular user' do
    it 'redirects to login' do
      user = create(:user)
      login_as(user)

      get(new_admin_path)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_url)
    end
  end

  context 'as an admin' do
    it 'returns status success' do
      admin = create(:user, role: :admin)
      login_as(admin)

      get(new_admin_path)

      expect(response).to have_http_status(:success)
    end
  end
end
