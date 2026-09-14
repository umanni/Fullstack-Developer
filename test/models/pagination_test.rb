require "test_helper"

class PaginationTest < ActiveSupport::TestCase
  setup do
    @scope = User.ordered
    @total = User.count
  end

  test "treats a missing, zero or negative page as the first page" do
    [ nil, "", "0", "-3", "not a number" ].each do |page|
      assert_equal 1, Pagination.new(@scope, page: page).number, "page: #{page.inspect}"
    end
  end

  test "returns at most per_page records" do
    page = Pagination.new(@scope, page: 1, per_page: 1)

    assert_equal 1, page.visible.size
  end

  test "reports a next page without counting the whole table" do
    page = Pagination.new(@scope, page: 1, per_page: 1)

    assert_predicate page, :next?
    assert_not page.previous?
    assert_equal 2, page.records.size
  end

  test "reports no next page on the last one" do
    page = Pagination.new(@scope, page: @total, per_page: 1)

    assert_not page.next?
    assert_predicate page, :previous?
  end

  test "does not repeat records across pages" do
    first = Pagination.new(@scope, page: 1, per_page: 1).visible
    second = Pagination.new(@scope, page: 2, per_page: 1).visible

    assert_empty first & second
  end
end
