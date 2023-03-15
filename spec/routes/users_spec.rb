require 'rails_helper'

RSpec.describe "User routes", type: :routing do
  # Test for the routes of the devise_for :users in config/routes.rb
  it "routes to user registrations controller" do
    expect(get: "/users/sign_up").to route_to("users/registrations#new")
    expect(post: "/users").to route_to("users/registrations#create")
  end

  it "routes to user sessions controller" do
    expect(get: "/users/sign_in").to route_to("users/sessions#new")
    expect(post: "/users/sign_in").to route_to("users/sessions#create")
  end

  it "routes to user passwords controller" do
    expect(get: "/users/password/new").to route_to("users/passwords#new")
    expect(get: "/users/password/edit").to route_to("users/passwords#edit")
    expect(patch: "/users/password").to route_to("users/passwords#update")
    expect(put: "/users/password").to route_to("users/passwords#update")
    expect(post: "/users/password").to route_to("users/passwords#create")
  end

  it "routes to user confirmations controller" do
    expect(get: "/users/confirmation/new").to route_to("users/confirmations#new")
    expect(get: "/users/confirmation").to route_to("users/confirmations#show")
    expect(post: "/users/confirmation").to route_to("users/confirmations#create")
  end
end
