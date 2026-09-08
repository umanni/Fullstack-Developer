# frozen_string_literal: true

module Users
  # Reads the admin user list: search, stable ordering, avatar preloading and
  # pagination. Pagy is isolated here — the controller never sees it (DIP).
  class ListingQuery
    ORDER = Arel.sql("LOWER(full_name) ASC, id ASC").freeze
    PER_PAGE = 10

    def self.call(scope: User.all, search: nil, page: nil)
      new(scope: scope, search: search, page: page).call
    end

    def initialize(scope: User.all, search: nil, page: nil)
      @scope = scope
      @search = search
      @page = page
    end

    def call
      filtered = search_filter(scope.with_attached_avatar.order(ORDER))
      pagy = Pagy.new(count: filtered.count, page: safe_page(filtered.count), limit: PER_PAGE)

      Users::Listing.new(
        users: filtered.offset(pagy.offset).limit(pagy.in),
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

    attr_reader :scope, :search, :page

    def search_filter(relation)
      return relation if search.blank?

      term = "%#{ActiveRecord::Base.sanitize_sql_like(search.to_s).downcase}%"
      relation.where("LOWER(full_name) LIKE :term OR LOWER(email_address) LIKE :term", term: term)
    end

    def safe_page(count)
      requested = Integer(page, exception: false) || 1
      last = [ 1, (count.to_f / PER_PAGE).ceil ].max
      requested.clamp(1, last)
    end
  end
end
