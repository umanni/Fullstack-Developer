require "test_helper"

class Users::ListingQueryTest < ActiveSupport::TestCase
  test "returns all users ordered by name then id with pagination metadata" do
    listing = Users::ListingQuery.call

    assert_equal users(:one, :two).map(&:full_name).sort, listing.users.map(&:full_name)
    assert_equal 2, listing.pagination[:count]
    assert_equal 1, listing.pagination[:page]
    assert_equal 1, listing.pagination[:pages]
    assert_nil listing.pagination[:prev]
    assert_nil listing.pagination[:next]
    assert_equal 10, listing.pagination[:items]
  end

  test "filters by full name case-insensitively" do
    listing = Users::ListingQuery.call(search: "IVY")

    assert_equal [ "Ivy Admin" ], listing.users.map(&:full_name)
  end

  test "filters by email address" do
    listing = Users::ListingQuery.call(search: users(:two).email_address)

    assert_equal [ users(:two) ], listing.users.to_a
  end

  test "escapes wildcard characters in the search term" do
    listing = Users::ListingQuery.call(search: "%")

    assert_empty listing.users
  end

  test "paginates once count exceeds the page size and clamps out-of-range pages" do
    12.times do |index|
      User.create!(
        full_name: "Bulk #{format("%02d", index + 10)}",
        email_address: "bulk#{index}@iam.test",
        password: "Password123!",
        role: :user,
        avatar_url: "https://example.com/avatars/bulk#{index}.png"
      )
    end

    listing = Users::ListingQuery.call(page: 2)

    assert_equal 2, listing.pagination[:page]
    assert_equal 14, listing.pagination[:count]
    assert_equal 2, listing.pagination[:pages]
    assert_equal 4, listing.users.length

    clamped = Users::ListingQuery.call(page: 99)
    assert_equal 2, clamped.pagination[:page]
  end

  test "blanks and non-numeric pages fall back to the first page" do
    assert_equal 1, Users::ListingQuery.call(page: "abc").pagination[:page]
    assert_equal 1, Users::ListingQuery.call(page: "").pagination[:page]
  end
end
