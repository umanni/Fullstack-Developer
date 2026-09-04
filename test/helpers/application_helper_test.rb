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

  test "role switch marks the current role as active" do
    def current_user = users(:admin)

    html = role_switch_for(users(:member))

    assert_match(/Member/, html)
    assert_match(/Admin/, html)
    assert_match(/bg-white text-slate-900/, html)
  end

  test "avatar tag falls back to initials" do
    html = avatar_tag(users(:member), size: 40)

    assert_includes html, "MM"
    assert_includes html, "width: 40px"
  end

  test "avatar tag uses remote url" do
    user = users(:member)
    user.avatar_url = "https://example.com/a.png"
    html = avatar_tag(user, size: 48)

    assert_includes html, "https://example.com/a.png"
    assert_includes html, "width: 48px"
    assert_includes html, "height: 48px"
  end
end
