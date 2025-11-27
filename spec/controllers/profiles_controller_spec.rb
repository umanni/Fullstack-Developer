require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show
      expect(response).to be_successful
    end

    it 'assigns current user' do
      get :show
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'GET #edit' do
    it 'returns a successful response' do
      get :edit
      expect(response).to be_successful
    end

    it 'assigns current user' do
      get :edit
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      let(:valid_params) do
        {
          user: {
            full_name: 'Updated Name',
            email: user.email
          }
        }
      end

      it 'updates the user' do
        patch :update, params: valid_params
        user.reload
        expect(user.full_name).to eq('Updated Name')
      end

      it 'redirects to profile' do
        patch :update, params: valid_params
        expect(response).to redirect_to(profile_path)
      end

      it 'shows success notice' do
        patch :update, params: valid_params
        expect(flash[:notice]).to eq('Profile updated successfully.')
      end
    end

    context 'with password change' do
      let(:password_params) do
        {
          user: {
            full_name: user.full_name,
            email: user.email,
            current_password: 'password123',
            password: 'newpassword123',
            password_confirmation: 'newpassword123'
          }
        }
      end

      it 'updates password when current password is correct' do
        patch :update, params: password_params
        user.reload
        expect(user.valid_password?('newpassword123')).to be true
      end

      it 'requires current password to change password' do
        params_without_current = {
          user: {
            full_name: user.full_name,
            email: user.email,
            password: 'newpassword123',
            password_confirmation: 'newpassword123'
          }
        }
        patch :update, params: params_without_current
        expect(response).to have_http_status(:unprocessable_entity)
        expect(assigns(:user).errors[:current_password]).to be_present
      end

      it 'rejects invalid current password' do
        params_with_wrong_password = {
          user: {
            full_name: user.full_name,
            email: user.email,
            current_password: 'wrongpassword',
            password: 'newpassword123',
            password_confirmation: 'newpassword123'
          }
        }
        patch :update, params: params_with_wrong_password
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with email change' do
      let(:email_params) do
        {
          user: {
            full_name: user.full_name,
            email: 'newemail@example.com',
            current_password: 'password123'
          }
        }
      end

      it 'requires current password to change email' do
        params_without_current = {
          user: {
            full_name: user.full_name,
            email: 'newemail@example.com'
          }
        }
        patch :update, params: params_without_current
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'updates email when current password is correct' do
        patch :update, params: email_params
        user.reload
        expect(user.email).to eq('newemail@example.com')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          user: {
            full_name: '',
            email: 'invalid-email'
          }
        }
      end

      it 'does not update the user' do
        original_name = user.full_name
        patch :update, params: invalid_params
        user.reload
        expect(user.full_name).to eq(original_name)
      end

      it 'renders edit template' do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
      end
    end

    context 'when password is blank' do
      it 'removes password and password_confirmation from params' do
        params_with_blank_password = {
          user: {
            full_name: user.full_name,
            email: user.email,
            password: '',
            password_confirmation: ''
          }
        }
        allow_any_instance_of(ActionController::Parameters).to receive(:delete).and_call_original
        patch :update, params: params_with_blank_password
        user.reload
        expect(user.valid_password?('password123')).to be true # Senha original ainda funciona
      end
    end

    context 'when only email changes' do
      it 'requires current password' do
        params_email_only = {
          user: {
            full_name: user.full_name,
            email: 'newemail@example.com'
          }
        }
        patch :update, params: params_email_only
        expect(response).to have_http_status(:unprocessable_entity)
        expect(assigns(:user).errors[:current_password]).to be_present
      end
    end

    context 'when only password changes' do
      it 'requires current password' do
        params_password_only = {
          user: {
            full_name: user.full_name,
            email: user.email,
            password: 'newpass123',
            password_confirmation: 'newpass123'
          }
        }
        patch :update, params: params_password_only
        expect(response).to have_http_status(:unprocessable_entity)
        expect(assigns(:user).errors[:current_password]).to be_present
      end
    end

    context 'when both password and email change' do
      it 'requires current password' do
        params_both = {
          user: {
            full_name: user.full_name,
            email: 'newemail@example.com',
            password: 'newpass123',
            password_confirmation: 'newpass123'
          }
        }
        patch :update, params: params_both
        expect(response).to have_http_status(:unprocessable_entity)
        expect(assigns(:user).errors[:current_password]).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the user' do
      expect {
        delete :destroy
      }.to change(User, :count).by(-1)
    end

    it 'redirects to root path' do
      delete :destroy
      expect(response).to redirect_to(root_path)
    end

    it 'signs out the user' do
      expect(controller).to receive(:sign_out).with(user)
      delete :destroy
    end

    it 'shows success notice' do
      delete :destroy
      expect(flash[:notice]).to eq('Your account has been deleted successfully.')
    end
  end

  describe 'authorization' do
    it 'authorizes user for show' do
      expect_any_instance_of(Pundit::Authorization).to receive(:authorize).with(user)
      get :show
    end

    it 'authorizes user for edit' do
      expect_any_instance_of(Pundit::Authorization).to receive(:authorize).with(user)
      get :edit
    end

    it 'authorizes user for update' do
      expect_any_instance_of(Pundit::Authorization).to receive(:authorize).with(user)
      patch :update, params: { user: { full_name: 'Test' } }
    end

    it 'authorizes user for destroy' do
      expect_any_instance_of(Pundit::Authorization).to receive(:authorize).with(user)
      delete :destroy
    end
  end
end

