require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    before do
      allow(controller).to receive(:assert_is_devise_resource!).and_return(true)
      warden_double = double('warden', no_input_strategies: [], user: nil)
      @request.env['warden'] = warden_double
      allow(controller).to receive(:warden).and_return(warden_double)
    end

    let(:valid_params) do
      {
        user: {
          full_name: 'Test User',
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end

    it 'creates a new user with role user' do
      sanitizer = instance_double(Devise::ParameterSanitizer)
      allow(controller).to receive(:devise_parameter_sanitizer).and_return(sanitizer)
      expect(sanitizer).to receive(:permit).with(:sign_up, keys: [:full_name])
      controller.send(:configure_sign_up_params)
    end

    it 'permits full_name parameter' do
      sanitizer = instance_double(Devise::ParameterSanitizer)
      allow(controller).to receive(:devise_parameter_sanitizer).and_return(sanitizer)
      expect(sanitizer).to receive(:permit).with(:sign_up, keys: [:full_name])
      controller.send(:configure_sign_up_params)
    end
  end

  describe '#build_resource' do
    it 'sets role to user by default' do
      resource = controller.send(:build_resource)
      expect(resource).to be_present
      expect(resource.role).to eq('user')
    end
  end

  describe '#after_sign_up_path_for' do
    let(:user) { create(:user) }

    it 'returns profile path' do
      expect(controller.send(:after_sign_up_path_for, user)).to eq(profile_path)
    end
  end

  describe '#configure_account_update_params' do
    it 'permits full_name and avatar_url' do
      sanitizer = controller.send(:devise_parameter_sanitizer)
      expect(sanitizer).to receive(:permit).with(:account_update, keys: [:full_name, :avatar_url])
      controller.send(:configure_account_update_params)
    end
  end
end

