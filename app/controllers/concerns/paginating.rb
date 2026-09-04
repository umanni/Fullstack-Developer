# Pagination for both faces of the application, and the one place that decides
# what an unreasonable request means. A page number that is empty, negative or
# not a number at all reaches Pagy as zero and raises; a page size read from
# the query string would otherwise let a hand-edited URL ask for the whole
# table in one response.
module Paginating
  extend ActiveSupport::Concern
  include Pagy::Backend

  MAX_PER_PAGE = 100

  private

  def paginate(scope, default_limit: Pagy::DEFAULT[:limit])
    pagy(scope, page: requested_page, limit: requested_limit(default_limit))
  end

  def requested_page
    [params[:page].to_i, 1].max
  end

  def requested_limit(default)
    requested = params[:per_page].to_i
    return default if requested <= 0

    requested.clamp(1, MAX_PER_PAGE)
  end
end
