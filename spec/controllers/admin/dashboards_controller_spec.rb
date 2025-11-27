require 'rails_helper'

RSpec.describe Admin::DashboardsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  before do
    sign_in admin
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show
      expect(response).to be_successful
    end

    it 'assigns total users' do
      create_list(:user, 3)
      get :show
      expect(assigns(:total_users)).to eq(4) # 3 created + admin
    end

    it 'assigns total admins' do
      create_list(:user, 2, :admin)
      get :show
      expect(assigns(:total_admins)).to eq(3) # 2 created + current admin
    end

    it 'assigns total regular users' do
      create_list(:user, 2)
      get :show
      expect(assigns(:total_regular_users)).to eq(2)
    end

    it 'assigns total guests' do
      get :show
      expect(assigns(:total_guests)).to eq(0)
    end

    it 'assigns users by role' do
      create(:user, :admin)
      create(:user)
      get :show
      expect(assigns(:users_by_role)).to include(
        admin: 2,
        user: 1,
        guest: 0
      )
    end
  end

  describe 'authorization' do
    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'redirects or denies access' do
        get :show
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Access denied.')
      end
    end
  end
end

