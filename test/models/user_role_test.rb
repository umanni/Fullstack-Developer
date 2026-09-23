require "test_helper"

class UserRoleTest < ActiveSupport::TestCase
  test "admin and non_admin helpers" do
    assert UserRole.admin.is_admin?
    assert_not UserRole.non_admin.is_admin?
  end

  test "requires unique label" do
    role = UserRole.new(label: "Admin", is_admin: false)
    assert_not role.valid?
  end
end
