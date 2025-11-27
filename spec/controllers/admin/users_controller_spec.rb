require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let!(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in admin
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns all users' do
      get :index
      expect(assigns(:users)).to include(admin, regular_user)
    end
  end

  describe 'GET #show' do
    it 'redirects to users index' do
      get :show, params: { id: regular_user.id }
      expect(response).to redirect_to(admin_users_path)
    end

    it 'authorizes the user' do
      expect_any_instance_of(Pundit::Authorization).to receive(:authorize).with(regular_user)
      get :show, params: { id: regular_user.id }
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          user: {
            full_name: 'Test User',
            email: 'test@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            role: 'user'
          }
        }
      end

      it 'creates a new user' do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'redirects to users index' do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_users_path)
      end

      it 'shows success notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq('User created successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          user: {
            full_name: '',
            email: 'invalid'
          }
        }
      end

      it 'does not create a user' do
        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)
      end

      it 'renders new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns a successful response' do
      get :edit, params: { id: regular_user.id }
      expect(response).to be_successful
    end

    it 'assigns the user' do
      get :edit, params: { id: regular_user.id }
      expect(assigns(:user)).to eq(regular_user)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      let(:update_params) do
        {
          id: regular_user.id,
          user: {
            full_name: 'Updated Name',
            email: regular_user.email,
            role: regular_user.role
          }
        }
      end

      it 'updates the user' do
        patch :update, params: update_params
        regular_user.reload
        expect(regular_user.full_name).to eq('Updated Name')
      end

      it 'redirects to users index' do
        patch :update, params: update_params
        expect(response).to redirect_to(admin_users_path)
      end

      it 'shows success notice' do
        patch :update, params: update_params
        expect(flash[:notice]).to eq('User updated successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_update_params) do
        {
          id: regular_user.id,
          user: {
            full_name: '',
            email: 'invalid-email'
          }
        }
      end

      it 'does not update the user' do
        original_name = regular_user.full_name
        patch :update, params: invalid_update_params
        regular_user.reload
        expect(regular_user.full_name).to eq(original_name)
      end

      it 'renders edit template' do
        patch :update, params: invalid_update_params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'PATCH #toggle_role' do
    it 'toggles user role from user to admin' do
      expect {
        patch :toggle_role, params: { id: regular_user.id }
        regular_user.reload
      }.to change { regular_user.role }.from('user').to('admin')
    end

    it 'toggles user role from admin to user' do
      admin_user = create(:user, :admin)
      expect {
        patch :toggle_role, params: { id: admin_user.id }
        admin_user.reload
      }.to change { admin_user.role }.from('admin').to('user')
    end

    it 'shows success notice when toggling role' do
      patch :toggle_role, params: { id: regular_user.id }
      expect(flash[:notice]).to match(/User role changed to (user|admin)/)
    end

    it 'redirects to users index after toggle' do
      patch :toggle_role, params: { id: regular_user.id }
      expect(response).to redirect_to(admin_users_path)
    end

    it 'prevents admin from changing own role' do
      patch :toggle_role, params: { id: admin.id }
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq('You cannot change your own role.')
      admin.reload
      expect(admin.role).to eq('admin')
    end

    it 'authorizes user for toggle_role' do
      expect_any_instance_of(Pundit::Authorization).to receive(:authorize).with(regular_user, :toggle_role?)
      patch :toggle_role, params: { id: regular_user.id }
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the user' do
      user_to_delete = create(:user)
      expect {
        delete :destroy, params: { id: user_to_delete.id }
      }.to change(User, :count).by(-1)
    end

    it 'prevents admin from deleting own account' do
      delete :destroy, params: { id: admin.id }
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq('You cannot delete your own account from here.')
    end

    it 'shows success notice when deleting other user' do
      user_to_delete = create(:user)
      delete :destroy, params: { id: user_to_delete.id }
      expect(flash[:notice]).to eq('User deleted successfully.')
    end
  end

  describe 'authorization' do
    context 'when user is not admin' do
      before do
        sign_in regular_user
      end

      it 'denies access to index' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Access denied.')
      end
    end
  end
end

