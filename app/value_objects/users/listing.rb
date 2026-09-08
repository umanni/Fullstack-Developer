# frozen_string_literal: true

module Users
  # Immutable result of Users::ListingQuery: the page of users plus its
  # pagination metadata. Keeps the query's contract explicit (no loose hash).
  class Listing
    def initialize(users:, pagination:)
      @users = users.to_a.freeze
      @pagination = pagination.freeze
      freeze
    end

    attr_reader :users, :pagination
  end
end
