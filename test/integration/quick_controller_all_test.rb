require "test_helper"
class QuickControllerAllTest < ActionDispatch::IntegrationTest
  test "all controllers respond" do
    assert defined?(SessionsController)
    assert defined?(RegistrationsController)
    assert defined?(ProfilesController)
    assert defined?(PasswordsController)
    assert defined?(Admin::DashboardController)
    assert defined?(Admin::UsersController)
    assert defined?(Admin::UserImportsController)
  end
end
