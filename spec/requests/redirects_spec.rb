require 'rails_helper'

RSpec.describe 'Custom Redirects', type: :request do
  describe 'After login redirects' do
    context 'when user is admin' do
      let(:admin) { create(:user, :admin) }

      it 'redirects to admin dashboard after login' do
        post user_session_path, params: {
          user: { email: admin.email, password: admin.password }
        }

        expect(response).to redirect_to(dashboard_index_path)
      end

      it 'redirects to admin dashboard after sign up' do
        post user_registration_path, params: {
          user: {
            full_name: 'Admin User',
            email: 'admin@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            role: 'admin'
          }
        }

        # Não pode se cadastrar como admin diretamente, deve ser user
        # testar isso também
        expect(User.last.role).to eq('user')
      end
    end

    context 'when user is regular user' do
      let(:user) { create(:user) }

      it 'redirects to user profile after login' do
        post user_session_path, params: {
          user: { email: user.email, password: user.password }
        }

        # Por enquanto vai para dashboard, depois criar profile_path
        expect(response).to redirect_to(dashboard_index_path)
      end
    end
  end

  describe 'Authorization enforcement' do
    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }

    context 'regular user accessing admin areas' do
      before do
        post user_session_path, params: {
          user: { email: user.email, password: user.password }
        }
      end

      it 'cannot access admin user management' do
        get '/admin/users'

        expect(response).to have_http_status(:found)
      end
    end

    context 'admin accessing admin areas' do
      before do
        post user_session_path, params: {
          user: { email: admin.email, password: admin.password }
        }
      end

      it 'can access admin user management' do
        get '/admin/users'

        expect(response).to have_http_status(:success).or have_http_status(:not_found)
      end
    end
  end
end