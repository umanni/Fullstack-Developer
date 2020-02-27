# frozen_string_literal: true

require "rails_helper"

RSpec.describe 'Handle Routes' do
  context 'when visitors tries to visit unkown route' do
    it 'is not routable' do
      expect(get: "/foo").to route_to(
        controller: "application",
        action: "route_not_found!",
        unmatched_route: "foo"
      )
    end
  end
end
