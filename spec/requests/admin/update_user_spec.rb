require "rails_helper"

describe 'PATCH /admin/id', type: :request do
  context 'before login' do
    it 'redirects to login' do
      user1 = create(:user)
      user2 = create(:user, full_name: 'Abel A', email: 'a@email.com')

      patch(admin_path(user2.id), params: { user: { full_name: 'Abel B', email: 'b@email.com' } })

      expect(response).to redirect_to(new_user_session_url)
    end
  end

  context 'as a regular user' do
    it 'redirects to login' do
      user1 = create(:user)
      user2 = create(:user, full_name: 'Abel A', email: 'a@email.com')
      login_as(user1)

      patch(admin_path(user2.id), params: { user: { full_name: 'Abel B', email: 'b@email.com' } })

      expect(response).to redirect_to(root_url)
    end
  end

  context 'as an admin' do
    it 'updates the user' do
      admin = create(:user, role: :admin)
      user = create(:user, full_name: 'Abel A', email: 'a@email.com')
      login_as(admin)

      patch(admin_path(user.id), params: { user: { full_name: 'Abel B', email: 'b@email.com', role: 'admin' } })
      user.reload

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(admin_dashboard_url)
      expect(user.full_name).to eq('Abel B')
      expect(user.email).to eq('b@email.com')
      expect(user.admin?).to eq(true)
    end
  end
end
