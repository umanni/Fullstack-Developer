require 'rails_helper'

RSpec.describe "Admin Dashboard", type: :request do
  let!(:admin) { create(:user, :admin) }
  let!(:users) { create_list(:user, 3) }

  
  before do
    post user_session_path, params: { user: { username: admin.username, password: 'senha123' } }
  end

  it "shows total number of users" do
    get admin_users_path
   
    expect(response.body).to include("Total users")
    expect(response.body).to include("4")
  end
end
