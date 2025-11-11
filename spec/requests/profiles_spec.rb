require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /profile' do
    it 'renders the profile page successfully' do
      get profile_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.full_name)
      expect(response.body).to include(user.email)
    end
  end

  describe 'PATCH /profile' do
    it 'updates the user information' do
      patch profile_path, params: { user: { full_name: 'Updated Name' } }

      expect(response).to redirect_to(profile_path)
      follow_redirect!

      expect(response.body).to include('Perfil atualizado com sucesso')
      expect(response.body).to include('Updated Name')
    end

    it 're-renders edit when invalid' do
      patch profile_path, params: { user: { email: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /profile' do
    it 'deletes the current user' do
      delete profile_path

      expect(response).to redirect_to(root_path)
      expect(User.exists?(user.id)).to be_falsey
    end
  end

  describe 'access control' do
    it 'prevents user from accessing another profile' do
      other_user = create(:user)
      get edit_profile_path, params: { id: other_user.id }

      expect(response).to redirect_to(root_path)
      follow_redirect!

      expect(response.body).to include('Acesso não autorizado')
    end
  end
end
