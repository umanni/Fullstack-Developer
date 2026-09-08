# frozen_string_literal: true

module UserImports
  # Reads the admin import history: newest first, paginated. Pagy is isolated
  # here — the controller never sees it (DIP), mirroring Users::ListingQuery.
  class ListingQuery
    PER_PAGE = 10
    ORDER = Arel.sql("id DESC").freeze

    def self.call(scope: UserImport.all, page: nil)
      new(scope: scope, page: page).call
    end

    def initialize(scope: UserImport.all, page: nil)
      @scope = scope
      @page = page
    end

    def call
      relation = scope.order(ORDER)
      count = relation.count
      pagy = Pagy.new(count: count, page: safe_page(count), limit: PER_PAGE)

      UserImports::Listing.new(
        imports: relation.offset(pagy.offset).limit(pagy.in),
        pagination: {
          page: pagy.page,
          pages: pagy.last,
          count: pagy.count,
          items: pagy.limit,
          prev: pagy.prev,
          next: pagy.next
        }
      )
    end

    private

    attr_reader :scope, :page

    def safe_page(count)
      requested = Integer(page, exception: false) || 1
      last = [ 1, (count.to_f / PER_PAGE).ceil ].max
      requested.clamp(1, last)
    end
  end
end
