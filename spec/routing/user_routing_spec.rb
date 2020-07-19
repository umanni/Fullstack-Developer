require "rails_helper"

RSpec.describe UserController, type: :routing do
  describe "routing" do
    it "routes to #profile" do
      expect(get: "/user/profile").to route_to("user#profile")
    end
  end
end
