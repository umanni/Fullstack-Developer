# frozen_string_literal: true

module UserImports
  # Immutable result of UserImports::ListingQuery — keeps pagy out of the
  # controller (DIP), mirroring Users::Listing.
  class Listing
    def initialize(imports:, pagination:)
      @imports = imports.to_a.freeze
      @pagination = pagination.freeze
      freeze
    end

    attr_reader :imports, :pagination
  end
end
