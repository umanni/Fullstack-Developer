require "test_helper"

# Proves DRY between the Ruby presenters/serializers and the frontend TS
# contracts (app/frontend/types/index.ts): a presenter that drifts from its
# TS interface fails the suite, keeping both sides in lockstep (fase-10).
class PresenterContractTest < ActiveSupport::TestCase
  TYPES_SOURCE = Rails.root.join("app/frontend/types/index.ts").read.freeze

  def ts_fields(interface)
    block = TYPES_SOURCE.match(/export type #{interface} = (?:\w+ & )?\{(.*?)\n\}/m)
    raise "TS interface #{interface} not found" unless block

    block[1].lines.map { |line| line[/^\s*(\w+)\??:/, 1] }.compact
  end

  def intersection?(interface)
    TYPES_SOURCE.match?(/export type #{interface} = \w+ & \{/)
  end

  def assert_matches_interface(serialized, interface)
    ruby = serialized.keys.map(&:to_s)
    ts = ts_fields(interface)

    if intersection?(interface)
      missing = ts - ruby
      assert_empty missing, "#{interface} expects missing keys #{missing.inspect}"
    else
      assert_empty ruby - ts, "#{interface} doesn't know #{(ruby - ts).inspect}"
      assert_empty ts - ruby, "#{interface} expects missing keys #{(ts - ruby).inspect}"
    end
  end

  test "UserPresenter matches the User TS interface" do
    assert_matches_interface UserPresenter.new(users(:one)).to_inertia, "User"
  end

  test "Users::Overview matches the UsersOverview TS interface" do
    overview = Users::Overview.new(total_users: 2, by_role: { "user" => 1, "admin" => 1 })
    assert_matches_interface overview.to_inertia, "UsersOverview"
  end

  test "UserImportPresenter matches the AdminImport TS interface" do
    assert_matches_interface UserImportPresenter.new(user_imports(:one)).to_inertia, "AdminImport"
  end

  test "admin user items match the AdminUser TS interface" do
    item = UserPresenter.new(users(:one)).to_inertia.merge(
      edit_url: "/admin/users/1/edit",
      toggle_url: "/admin/users/1/toggle",
      delete_url: "/admin/users/1"
    )
    assert_matches_interface item, "AdminUser"
  end

  test "admin import list items match the AdminImportListItem TS interface" do
    item = UserImportPresenter.new(user_imports(:one)).to_inertia.merge(show_url: "/admin/user_imports/1")
    assert_matches_interface item, "AdminImportListItem"
  end

  test "listing pagination matches the Pagination TS interface" do
    pagination = { page: 1, pages: 2, count: 20, items: 10, prev: nil, next: nil }
    assert_matches_interface pagination, "Pagination"
  end
end
