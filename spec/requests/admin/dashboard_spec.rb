require 'rails_helper'

RSpec.describe 'Admin::Dashboard', type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:user)  { create(:user) }

  describe 'GET /admin/dashboard' do
    context 'when admin is signed in' do
      before { sign_in admin }

      it 'returns JSON metrics of users' do
        get '/admin/dashboard'

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json).to include('total_users', 'users_by_role')
        expect(json['users_by_role']).to be_a(Hash)
      end
    end

    context 'when regular user is signed in' do
      before { sign_in user }

      it 'redirects to root with alert' do
        get '/admin/dashboard'

        expect(response).to redirect_to(root_path)
        follow_redirect!

        expect(response.body).to include('Acesso restrito a administradores')
      end
    end

    context 'when not authenticated' do
      it 'redirects to sign in' do
        get '/admin/dashboard'
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
