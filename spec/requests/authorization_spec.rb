require 'rails_helper'

RSpec.describe 'Authorization', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe 'Admin-only actions' do
    # Criar um endpoint de teste posteriormente
    # Por enquanto testar o conceito com helpers

    it 'admin can access admin areas' do
      post user_session_path, params: {
        user: { email: admin.email, password: admin.password }
      }

      get dashboard_index_path
      expect(response).to have_http_status(:success)
    end

    it 'regular user can access user areas' do
      post user_session_path, params: {
        user: { email: user.email, password: user.password }
      }

      get dashboard_index_path
      expect(response).to have_http_status(:success)
    end

    it 'unauthenticated user is redirected to login' do
      get dashboard_index_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'Role switching' do
    it 'can promote user to admin' do
      expect(user.admin?).to be false
      user.admin!
      expect(user.admin?).to be true
    end

    it 'can demote admin to user' do
      expect(admin.admin?).to be true
      admin.user!
      expect(admin.user?).to be true
    end
  end
end