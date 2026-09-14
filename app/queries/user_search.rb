# app/queries/user_search.rb
class UserSearch
  PER_PAGE  = 20
  SORTABLE  = %w[full_name role created_at].freeze
  DIRECTIONS = %w[asc desc].freeze

  attr_reader :page

  def initialize(scope, params)
    @scope = scope
    @query = params[:query].to_s.strip
    @sort  = SORTABLE.include?(params[:sort].to_s) ? params[:sort].to_s : "created_at"
    @dir   = DIRECTIONS.include?(params[:direction].to_s) ? params[:direction].to_s : "desc"
    @role  = User.roles.key?(params[:role].to_s) ? params[:role].to_s : nil
    @page  = [ params[:page].to_i, 1 ].max
  end

  def records
    @records ||= filtered.order(@sort => @dir).offset((page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def total       = @total ||= filtered.count
  def total_pages = [ (total.to_f / PER_PAGE).ceil, 1 ].max

  def to_props
    { query: @query, sort: @sort, direction: @dir, role: @role,
      page: page, total_pages: total_pages, total: total }
  end

  private

  def filtered
    result = @scope
    result = result.where(role: @role) if @role
    result = result.where("full_name ILIKE ?", "%#{sanitize(@query)}%") if @query.present?
    result
  end

  def sanitize(term) = ActiveRecord::Base.sanitize_sql_like(term)
end
