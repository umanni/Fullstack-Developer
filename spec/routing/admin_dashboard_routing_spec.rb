require "rails_helper"

RSpec.describe Admin::DashboardController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/dashboard").to route_to("admin/dashboard#index")
    end
  end
end
