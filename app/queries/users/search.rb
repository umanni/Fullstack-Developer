module Users
  class Search
    PER_PAGE = 20
    Result = Data.define(:records, :query, :page, :total_pages, :total_count)

    def self.call(query:, page:)
      new(query:, page:).call
    end

    def initialize(query:, page:)
      @query = query.to_s.strip
      @page = [ page.to_i, 1 ].max
    end

    def call
      relation = User.with_attached_avatar_image.order(:full_name, :email)
      relation = filter(relation) if query.present?
      total_count = relation.count
      total_pages = [ (total_count.to_f / PER_PAGE).ceil, 1 ].max
      current_page = [ page, total_pages ].min
      records = relation.offset((current_page - 1) * PER_PAGE).limit(PER_PAGE)

      Result.new(records:, query:, page: current_page, total_pages:, total_count:)
    end

    private
      attr_reader :query, :page

      def filter(relation)
        term = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
        relation.where("full_name ILIKE :term OR email ILIKE :term", term:)
      end
  end
end
