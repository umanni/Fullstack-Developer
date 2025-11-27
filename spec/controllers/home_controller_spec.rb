require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    context 'when user is not signed in' do
      it 'renders index page' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is signed in' do
      context 'as admin' do
        let(:admin) { create(:user, :admin) }

        before { sign_in admin }

        it 'redirects to admin root path' do
          get :index
          expect(response).to redirect_to(admin_root_path)
        end
      end

      context 'as regular user' do
        let(:user) { create(:user) }

        before { sign_in user }

        it 'redirects to profile path' do
          get :index
          expect(response).to redirect_to(profile_path)
        end
      end
    end
  end
end

