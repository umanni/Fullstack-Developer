require 'rails_helper'

RSpec.describe HealthController, type: :controller do
  describe 'GET #check' do
    it 'returns ok status without authentication' do
      get :check
      expect(response).to have_http_status(:success)
    end

    it 'returns JSON with status and timestamp' do
      get :check
      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq('ok')
      expect(json_response['timestamp']).to be_present
    end

    it 'does not require authentication' do
      expect(controller).to receive(:check).and_call_original
      get :check
      expect(response).to have_http_status(:success)
    end
  end
end

