# Offset pagination without a gem and without a COUNT query: one extra row is fetched
# beyond the page, and its presence is what answers "is there a next page".
class Pagination
  PER_PAGE = 25
  # An OFFSET beyond this is a malformed request, not a page someone wants.
  LAST_PAGE = 1_000_000

  attr_reader :number

  def initialize(scope, page:, per_page: PER_PAGE)
    @scope = scope
    @number = Integer(page.to_s, exception: false)&.clamp(1, LAST_PAGE) || 1
    @per_page = per_page
  end

  def records
    @records ||= @scope.offset((number - 1) * @per_page).limit(@per_page + 1).to_a
  end

  def visible
    records.first(@per_page)
  end

  def next?
    records.size > @per_page
  end

  def previous?
    number > 1
  end
end
