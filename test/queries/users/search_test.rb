require "test_helper"

class Users::SearchTest < ActiveSupport::TestCase
  test "searches names and email addresses case-insensitively" do
    by_name = Users::Search.call(query: "grace", page: 1)
    by_email = Users::Search.call(query: "LINUS@", page: 1)

    assert_equal [ users(:member) ], by_name.records.to_a
    assert_equal [ users(:second_admin) ], by_email.records.to_a
  end

  test "escapes SQL wildcard characters" do
    result = Users::Search.call(query: "%_", page: 1)

    assert_empty result.records
  end

  test "clamps invalid and out-of-range pages" do
    first_page = Users::Search.call(query: nil, page: -10)
    final_page = Users::Search.call(query: nil, page: 10_000)

    assert_equal 1, first_page.page
    assert_equal first_page.total_pages, final_page.page
  end
end
