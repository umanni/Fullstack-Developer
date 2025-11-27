require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'OK'
    end
  end

  before do
    routes.draw { get 'index' => 'anonymous#index' }
  end

  describe 'CSRF protection' do
    it 'protects from forgery' do
      expect(controller.class.protect_from_forgery).to be_truthy
    end
  end

  describe '#configure_permitted_parameters' do
    let(:sanitizer) { instance_double(Devise::ParameterSanitizer) }
    
    before do
      allow(controller).to receive(:devise_controller?).and_return(true)
      allow(controller).to receive(:devise_parameter_sanitizer).and_return(sanitizer)
    end

    it 'permits full_name on sign_up' do
      expect(sanitizer).to receive(:permit).with(:sign_up, keys: [:full_name]).ordered
      expect(sanitizer).to receive(:permit).with(:account_update, keys: [:full_name, :avatar_url]).ordered
      controller.send(:configure_permitted_parameters)
    end

    it 'permits full_name and avatar_url on account_update' do
      expect(sanitizer).to receive(:permit).with(:sign_up, keys: [:full_name]).ordered
      expect(sanitizer).to receive(:permit).with(:account_update, keys: [:full_name, :avatar_url]).ordered
      controller.send(:configure_permitted_parameters)
    end
  end

  describe '#after_sign_in_path_for' do
    context 'when user is admin' do
      let(:admin) { create(:user, :admin) }

      it 'returns admin root path' do
        expect(controller.send(:after_sign_in_path_for, admin)).to eq(admin_root_path)
      end
    end

    context 'when user is regular user' do
      let(:user) { create(:user) }

      it 'returns profile path' do
        expect(controller.send(:after_sign_in_path_for, user)).to eq(profile_path)
      end
    end
  end

  describe '#after_sign_out_path_for' do
    it 'returns root path' do
      expect(controller.send(:after_sign_out_path_for, nil)).to eq(root_path)
    end
  end

  describe 'authentication' do
    it 'requires authentication by default' do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end

    context 'when user is signed in' do
      let(:user) { create(:user) }

      before { sign_in user }

      it 'allows access' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end
end

