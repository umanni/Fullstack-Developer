require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /users (Sign Up)' do
    let(:valid_attributes) do
      {
        user: {
          full_name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post user_registration_path, params: valid_attributes
        }.to change(User, :count).by(1)
      end

      it 'redirects to authenticated root' do
        post user_registration_path, params: valid_attributes
        expect(response).to redirect_to(authenticated_root_path)
      end

      it 'creates user with default role' do
        post user_registration_path, params: valid_attributes
        expect(User.last.role).to eq('user')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new user without full_name' do
        invalid_attributes = valid_attributes.deep_dup
        invalid_attributes[:user][:full_name] = ''
        
        expect {
          post user_registration_path, params: invalid_attributes
        }.not_to change(User, :count)
      end

      it 'does not create a new user with invalid email' do
        invalid_attributes = valid_attributes.deep_dup
        invalid_attributes[:user][:email] = 'invalid_email'
        
        expect {
          post user_registration_path, params: invalid_attributes
        }.not_to change(User, :count)
      end
    end
  end

  describe 'POST /users/sign_in (Login)' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'signs in the user' do
        post user_session_path, params: {
          user: { email: 'test@example.com', password: 'password123' }
        }
        expect(response).to redirect_to(authenticated_root_path)
      end
    end

    context 'with invalid credentials' do
      it 'does not sign in with wrong password' do
        post user_session_path, params: {
          user: { email: 'test@example.com', password: 'wrongpassword' }
        }
        expect(response).not_to redirect_to(authenticated_root_path)
      end
    end
  end

  describe 'DELETE /users/sign_out (Logout)' do
    let(:user) { create(:user) }

    it 'signs out the user' do
      post user_session_path, params: {
        user: { email: user.email, password: user.password }
      }

      delete destroy_user_session_path
      
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end
  end
end