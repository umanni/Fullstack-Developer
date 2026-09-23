require "test_helper"

class ImportTest < ActiveSupport::TestCase
  test "progress percent" do
    import = Import.new(user: users(:admin), filename: "users.csv", total_rows: 10, processed_rows: 4)
    assert_equal 40, import.progress_percent
  end

  test "progress percent is zero when empty" do
    import = Import.new(user: users(:admin), filename: "users.csv", total_rows: 0, processed_rows: 0)
    assert_equal 0, import.progress_percent
  end
end
