require 'rails_helper'

RSpec.describe "/admin/dashboard", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get admin_dashboard_index_url
      expect(response).to have_http_status(:success)
    end
  end

end
