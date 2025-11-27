require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
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
end

