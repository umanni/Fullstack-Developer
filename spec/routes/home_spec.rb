require 'rails_helper'

RSpec.describe 'Home page', type: :request do
  # Ensure that the home page is accessible
  it 'returns HTTP success' do
    get '/'
    expect(response).to have_http_status(:success)
  end
end
