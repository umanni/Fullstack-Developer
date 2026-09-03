require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "flash and role badge classes" do
    assert_match "emerald", flash_class(:notice)
    assert_match "rose", flash_class(:alert)
    assert_match "teal", role_badge_class("admin")
    assert_match "slate", role_badge_class("member")
  end

  test "import status classes" do
    assert_match "sky", import_status_class("processing")
    assert_match "emerald", import_status_class("completed")
  end

  test "avatar tag falls back to initials" do
    html = avatar_tag(users(:member), size: 40)
    assert_includes html, "MM"
  end

  test "avatar tag uses remote url" do
    user = users(:member)
    user.avatar_url = "https://example.com/a.png"
    html = avatar_tag(user)
    assert_includes html, "https://example.com/a.png"
  end
end
