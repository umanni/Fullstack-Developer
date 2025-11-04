require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  let!(:user) { create(:user, password: "senha123") }

  it "logs in with correct user and password" do

    post user_session_path, params: { user: { username: user.username, password: "senha123" } }
    expect([302, 303]).to include(response.status)

  end
end
