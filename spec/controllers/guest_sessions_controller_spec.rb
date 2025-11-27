require 'rails_helper'

RSpec.describe GuestSessionsController, type: :controller do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    it 'creates a guest user' do
      expect {
        post :create
      }.to change(User, :count).by(1)
    end

    it 'creates user with role user' do
      post :create
      user = User.last
      expect(user.role).to eq('user')
    end

    it 'creates user with guest email pattern' do
      post :create
      user = User.last
      expect(user.email).to match(/^guest_[a-f0-9]{16}@guest\.temp$/)
    end

    it 'creates user with default full_name' do
      post :create
      user = User.last
      expect(user.full_name).to eq('Usuário Visitante')
    end

    it 'signs in the guest user' do
      post :create
      expect(controller.current_user).to eq(User.last)
    end

    it 'redirects to profile path' do
      post :create
      expect(response).to redirect_to(profile_path)
    end

    it 'shows notice message' do
      post :create
      expect(flash[:notice]).to eq('Você entrou como visitante. Sua conta será temporária.')
    end

    it 'does not require authentication' do
      expect(controller).not_to receive(:authenticate_user!)
      post :create
    end
  end
end

