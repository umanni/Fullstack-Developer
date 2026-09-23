require "application_system_test_case"

class AdminUsersSystemTest < ApplicationSystemTestCase
  test "admin can open users index" do
    visit new_session_path
    fill_in "email", with: users(:admin).email
    fill_in "password", with: "password123"
    click_button "Entrar"
    assert_text "Painel"

    visit admin_users_path
    assert_current_path admin_users_path
    assert_selector "h1", text: "Usuários"
    assert_text users(:member).email
  end
end
