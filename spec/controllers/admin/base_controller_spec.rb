require 'rails_helper'

RSpec.describe Admin::BaseController, type: :controller do
  controller(Admin::BaseController) do
    def index
      render plain: 'OK'
    end
  end

  before do
    routes.draw { get 'index' => 'admin/base#index' }
  end

  describe 'layout' do
    it 'uses admin layout' do
      expect(controller.class._layout).to eq('admin')
    end
  end

  describe '#ensure_admin' do
    context 'when user is not signed in' do
      it 'redirects to sign in path' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not show access denied alert when not signed in' do
        get :index
        expect(flash[:alert]).not_to eq('Access denied.')
      end
    end

    context 'when user is regular user' do
      let(:user) { create(:user) }

      before { sign_in user }

      it 'redirects to root path' do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it 'shows access denied alert' do
        get :index
        expect(flash[:alert]).to eq('Access denied.')
      end
    end

    context 'when user is admin' do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      it 'allows access' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end
end

