require "rails_helper"

RSpec.describe Admin::UserBulksController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/user_bulks").to route_to("admin/user_bulks#index")
    end

    it "routes to #new" do
      expect(get: "/admin/user_bulks/new").to route_to("admin/user_bulks#new")
    end

    it "routes to #show" do
      expect(get: "/admin/user_bulks/1").to route_to("admin/user_bulks#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/user_bulks/1/edit").to route_to("admin/user_bulks#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/user_bulks").to route_to("admin/user_bulks#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/user_bulks/1").to route_to("admin/user_bulks#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/user_bulks/1").to route_to("admin/user_bulks#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/user_bulks/1").to route_to("admin/user_bulks#destroy", id: "1")
    end
  end
end
