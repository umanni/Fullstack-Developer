require 'rails_helper'

RSpec.describe 'Dashboard', type: :request do
  # Ensure that the dashboard page is accessible
  describe 'GET #index' do
    it 'returns HTTP success' do
      get '/dashboard'
      expect(response).to have_http_status(:success)
    end
  end
  
  # Ensure that the list_users page is accessible
  describe 'GET #list_users' do
    it 'returns HTTP success' do
      get '/list_users'
      expect(response).to have_http_status(:success)
    end
  end

  # Ensure that the new_user_bulk page is accessible
  describe 'GET #new_user_bulk' do
    it 'returns HTTP success' do
      get '/new_user_bulk'
      expect(response).to have_http_status(:success)
    end
  end
  
  # Ensure that the create_user_bulk page is accessible
  describe 'POST #create_user_bulk' do
    it 'returns HTTP success' do
      post '/create_user_bulk'
      expect(response).to have_http_status(:success)
    end
  end
end
